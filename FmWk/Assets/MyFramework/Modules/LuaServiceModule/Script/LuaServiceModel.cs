using System;
using LuaInterface;

namespace MyFramework
{
    public class LuaServiceModel : LuaModelControlBase<LuaServiceModel>
    {
        #region 模块项目配置
        public enum BASESOCKET_STATE
        {
            SOCKET_INITING,         //Socket已经初始化成功
            SOCKET_BINDING,         //Socket已经绑定到Ip：端口
            SOCKET_LISTENING,       //Socket已经在进行端口监听
            SOCKET_CONNECTING,      //Socket已经连接上服务器
            SOCKET_ERROR            //Socket发送错误
        }

        public enum SOCKET_CODE
        {
            SUCCESS,                //处理成功
            ERROR_STATE,            //状态错误
            ERROR_SOCKET,           //Socket套接字失效
            ERROR_BIND,             //绑定错误
            ERROR_CONNECT,          //连接错误
            ERROR_SEND,             //发送错误
            ERROR_RECV,             //接收错误
            ERROR_DATA              //数据内容错误
        }
        public delegate void ThreadDelegate();
        #endregion
        [MFWModel_SerializeName("远程服务器")]
        public string Ip;
        [MFWModel_SerializeName("远程TCP端口")]
        public int Port;
        public int UdpPort;
        private LuaServiceModelTcpComp TcpComp;
        private LuaServiceModelUdpComp UdpComp;
        private LuaServiceMessageComp MessageComp;
        private LuaFunction LuaDealMessage;
        public override void Load(params object[] _Agr)
        {
            if (_Agr.Length >= 2)
            {
                Ip = (string)_Agr[0];
                Port = Convert.ToInt32(_Agr[1]);
                if(_Agr.Length > 2)
                    UdpPort = Convert.ToInt32(_Agr[2]);
            }
            else
            {
                Ip = AppConfig.Ip;
                Port = AppConfig.Port;
                UdpPort = AppConfig.UdpPort;
            }
            TimerComp = AddComp<Model_TimerComp>();
            CoroutineComp = AddComp<Model_CoroutineComp>();
            TcpComp = AddComp<LuaServiceModelTcpComp>();
            UdpComp = AddComp<LuaServiceModelUdpComp>();
            MessageComp = AddComp<LuaServiceMessageComp>();
            LuaDealMessage = LuaManagerModel.Instance.GetFunction(ModelName + ".DealMessage");
            base.Load(_Agr);
        }

        public void SendMessage(byte ComId, byte MsgId, LuaByteBuffer buffer)
        {
            CSMessage Msg = new CSMessage();
            Msg.WriteMsg(ComId, MsgId, buffer.buffer);
            byte[] msg = Msg.ToBytes();
            LoggerHelper.Debug("发送消息 TCP ComId =" + Msg.Head.ComId + " MsgId = " + Msg.Head.MsgId+ " MsgLength"+ Msg.Head.MsgLength);
            TcpComp.SocketSend(msg, 0, msg.Length);
        }

        public void SendMesageUdp(byte ComId, byte MsgId, LuaByteBuffer buffer)
        {
            CSMessage Msg = new CSMessage();
            Msg.WriteMsg(ComId, MsgId, buffer.buffer);
            byte[] msg = Msg.ToBytes();
            LoggerHelper.Debug("发送消息 UDP ComId =" + Msg.Head.ComId + " MsgId = " + Msg.Head.MsgId);
            UdpComp.SendMsg(msg);
        }

        /// <summary>
        /// 接收到消息
        /// </summary>
        public int RecvMessage(byte[] buffer)
        {
            if (buffer.Length == 0)
            {
                return 0;
            }
            try
            {
                CSMessage msg = new CSMessage();
                int length = msg.ReadMsg(buffer);
                MessageComp.ReceiveMessage(msg);
                return length;
            }
            catch (Exception ex)
            {
                VP(0, () => {
                    Manager_ManagerModel.Instance.CloseModel<ServiceModel>();
                    LoggerHelper.Error("ServiceModel 解包异常" + ex.Message);
                });
                return 0;
            }
        }

        public void DealMessage(CSMessage Msg)
        {
            if (LuaDealMessage != null)
            {
                LuaDealMessage.Call<UInt16, UInt16, LuaByteBuffer>(Msg.Head.ComId, Msg.Head.MsgId, new LuaByteBuffer(Msg.Msg));
            }
        }

    }
}
