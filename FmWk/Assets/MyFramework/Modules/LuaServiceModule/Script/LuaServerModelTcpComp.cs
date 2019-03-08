using System;
using System.Linq;
using System.Net;
using System.Net.Sockets;

namespace MyFramework
{
    
    public class LuaServiceModelTcpComp : ModelCompBase<LuaServiceModel>
    {
        #region Editor输出
        [MFWModel_SerializeName("Tcp 连接状态")]
        private LuaServiceModel.BASESOCKET_STATE SocketState = LuaServiceModel.BASESOCKET_STATE.SOCKET_ERROR;
        #endregion

        #region 框架构造
        public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
        {
            base.Load(_ModelContorl);
            NetWork_TCP();
            if (SocketConnect() == LuaServiceModel.SOCKET_CODE.SUCCESS)
            {
                base.LoadEnd();
            }
            else
            {
                LoggerHelper.Error("连接服务器失败");
            }
        }

        public override void Close()
        {
            SocketDisconnect();
            base.Close();
        }
        #endregion
        private Socket socket;
       
        private int recvBufferSize = 20480;         //接收缓冲区空间大小
        private int maxPackage = 10240;             //数据包的最大长度
        private byte[] recvBuffer = null;           //接收缓冲区
        private byte[] backupBuffer = null;         //备份缓冲区，用来缓存半包


        public void NetWork_TCP()
        {
            socket = new Socket(AddressFamily.InterNetwork, System.Net.Sockets.SocketType.Stream, ProtocolType.Tcp);
            SocketState = LuaServiceModel.BASESOCKET_STATE.SOCKET_INITING;
            socket.SendTimeout = 500;
        }

        #region 连接
        //阻塞式连接,使用默认Ip端口进行连接
        public LuaServiceModel.SOCKET_CODE SocketConnect()
        {
            //如果Socket未初始化且不是绑定状态
            if (LuaServiceModel.BASESOCKET_STATE.SOCKET_INITING != SocketState
                && LuaServiceModel.BASESOCKET_STATE.SOCKET_BINDING != SocketState)
            {
                return LuaServiceModel.SOCKET_CODE.ERROR_STATE;
            }
            IPAddress addr = IPAddress.Parse(MyCentorl.Ip.Trim());
            try
            {
                //使用默认的端口和地址进行连接
                socket.Connect(addr, MyCentorl.Port);
            }
            catch (Exception e)
            {
                SocketState = LuaServiceModel.BASESOCKET_STATE.SOCKET_ERROR;
                return LuaServiceModel.SOCKET_CODE.ERROR_CONNECT;
            }
            //连接成功更新状态为已连接
            SocketState = LuaServiceModel.BASESOCKET_STATE.SOCKET_CONNECTING;
            //启动接收
            StartRecv();
            return LuaServiceModel.SOCKET_CODE.SUCCESS;
        }
        #endregion

        #region 关闭
        public void SocketClose()
        {
            if (socket != null)
            {
                socket.Close();
            }
        }
        public void SocketDisconnect()
        {
            if (socket != null && socket.Connected)
            {
                socket.Shutdown(SocketShutdown.Both);
            }
        }
        #endregion

        #region 接收
        private LuaServiceModel.SOCKET_CODE StartRecv()
        {
            if (LuaServiceModel.BASESOCKET_STATE.SOCKET_CONNECTING != SocketState)
            {
                return LuaServiceModel.SOCKET_CODE.ERROR_STATE;
            }

            if (recvBuffer == null)
            {
                recvBuffer = new byte[recvBufferSize];
            }

            socket.BeginReceive(recvBuffer, 0, recvBufferSize, SocketFlags.None, new AsyncCallback(OnRecv), null);

            return LuaServiceModel.SOCKET_CODE.SUCCESS;
        }

        private void OnRecv(IAsyncResult ar)
        {
            try
            {
                int recvLength = socket.EndReceive(ar);
                int pkgLength = 0;
                byte[] data;
                //如果半包数据不为空
                if (null != backupBuffer)
                {
                    //将半包和后面接收到的数据报拼接起来
                    data = backupBuffer.Concat(recvBuffer.Take(recvLength).ToArray()).ToArray();
                }
                else
                {
                    data = recvBuffer.Take(recvLength).ToArray();
                }
                //解决连包问题
                while (true)
                {
                    // 1. recvEvent返回一个完整的数据包长度
                    pkgLength = MyCentorl.RecvMessage(data);

                    if (pkgLength <= 0 || pkgLength > maxPackage)
                    {
                        //出现异常，连接关闭                    
                        SocketState = LuaServiceModel.BASESOCKET_STATE.SOCKET_ERROR;
                        Close();
                        break;
                    }

                    // 2. 如果正常处理完,则直接启动下次接收
                    if (pkgLength == data.Length)
                    {
                        ////TraceUtil.Log("正常");
                        backupBuffer = null;
                        Array.Clear(recvBuffer, 0, recvBuffer.Length);
                        pkgLength = 0;
                        break;
                    }
                    // 3. 如果还未接收完,半包则在偏移处等待
                    else if (pkgLength > data.Length)
                    {
                        //将半包数据拷贝到backupBuffer
                        ////TraceUtil.Log("半包");
                        backupBuffer = data.Take(data.Length).ToArray();
                        break;
                    }
                    // 4. 如果是连包，则循环处理
                    else if (pkgLength < data.Length)
                    {
                        //自增偏移量并跳过已经处理的包
                        ////TraceUtil.Log("连包");
                        data = data.Skip(pkgLength).ToArray();
                        backupBuffer = null;
                    }
                    else
                    {
                        break;
                    }
                }

                StartRecv();
            }
            catch
            {
                SocketState = LuaServiceModel.BASESOCKET_STATE.SOCKET_ERROR;
                Close();
            }
        }
        #endregion

        #region 发送

        //异步发送数据
        public LuaServiceModel.SOCKET_CODE SocketSend(byte[] data, int offset, int size)
        {
            //只有以下两种情况可以发送数据
            //1.当我是服务器，我可以对已经连接上我的客户端进行发送数据
            //2.当我是客户端，且已经连接上服务器
            //tcp服务端套接字只能用于接收连接，无法用于发送数据
            if (LuaServiceModel.BASESOCKET_STATE.SOCKET_CONNECTING != SocketState)
            {
                return LuaServiceModel.SOCKET_CODE.ERROR_STATE;
            }
            try
            {
                socket.BeginSend(data, offset, size, SocketFlags.None, new AsyncCallback(OnSend), null);
            }
            //当发生套接字错误，表示该套接字已经出现异常
            catch
            {
                SocketState = LuaServiceModel.BASESOCKET_STATE.SOCKET_ERROR;
                return LuaServiceModel.SOCKET_CODE.ERROR_SOCKET;
            }

            return LuaServiceModel.SOCKET_CODE.SUCCESS;
        }

        //结束异步发送
        private void OnSend(IAsyncResult ar)
        {
            socket.EndSend(ar);
        }

        #endregion
    }
}
