using System;
using System.Collections.Generic;

namespace MyFramework
{
    public class ServiceModel:ManagerContorBase<ServiceModel>
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

        public string Ip;
        public int Port;
        public int UdpPort;
        private ServiceModelTcpComp TcpComp;
        private ServiceModelUdpComp UdpComp;
        private ServiceMessageComp MessageComp;
        private Dictionary<int, IServiceSchedulerBase> Services;
        public override void Load(params object[] _Agr)
        {
            if (_Agr.Length >= 2)
            {
                Ip = (string)_Agr[0];
                Port = Convert.ToInt32(_Agr[1]);
                if (_Agr.Length > 2)
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
            Services = new Dictionary<int, IServiceSchedulerBase>();
            TcpComp = AddComp<ServiceModelTcpComp>();
            if( UdpPort != 0 )
                UdpComp = AddComp<ServiceModelUdpComp>();
            MessageComp = AddComp<ServiceMessageComp>();
            base.Load(_Agr);
        }

        public void SendMessage(CSMessage Msg)
        {
            byte[] msg = Msg.ToBytes();
            TcpComp.SocketSend(msg, 0, msg.Length);
        }

        public void SendMesageUdp(CSMessage Msg)
        {
            byte[] msg = Msg.ToBytes();
            LoggerHelper.Debug("发送消息 ComId =" + Msg.Head.ComId + " MsgId = " + Msg.Head.MsgId);
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
                LoggerHelper.Debug("协议消息Ok");
                return length;
            }
            catch (Exception ex)
            {
                LoggerHelper.Error("ServiceModel 解包异常" + ex.Message);
                VP(0,()=> {
                    Manager_ManagerModel.Instance.CloseModel<ServiceModel>();
                });
                return 0;
            }
        }

        /// <summary>
        /// 注册消息处理器
        /// </summary>
        /// <param name="CmdId"></param>
        /// <param name="_Scheduler"></param>
        public void RegisterScheduler(byte CmdId, IServiceSchedulerBase _Scheduler)
        {
            Services[CmdId] = _Scheduler;
        }

        public void DealMessage(CSMessage Msg)
        {
            if (Services.ContainsKey(Msg.Head.ComId))
            {
                Services[Msg.Head.ComId].DealMessage(Msg);
            }
            else
            {
                LoggerHelper.Error("ServiceModel 没有注册消息处理器 " + Msg.Head.ComId);
            }
        }

    }
}
