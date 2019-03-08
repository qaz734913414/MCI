using System;
using System.Net;
using System.Net.Sockets;

namespace MyFramework
{
    public class LuaServiceModelUdpComp : ModelCompBase<LuaServiceModel>
    {
        #region 框架构造
        public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
        {
            base.Load(_ModelContorl);
            NetWork_UDP();
            base.LoadEnd();
        }
        public override void Close()
        {

        }
        #endregion



        Socket socket;
        private class SocketState
        {
            public SocketState(Socket socket)
            {
                this.Buffer = new byte[1024];
                this.Socket = socket;
                this.RemoteEP = new IPEndPoint(IPAddress.Any, 0);
            }
            public Socket Socket { get; private set; }
            public byte[] Buffer { get; private set; }
            public EndPoint RemoteEP;
        }

        private void NetWork_UDP()
        {
            socket = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp);
            StartReceive();
        }

        private void StartReceive()
        {
            EndPoint localEP = new IPEndPoint(IPAddress.Any, 0);
            socket.Bind(localEP);
            SocketState state = new SocketState(socket);
            socket.BeginReceiveFrom(
                state.Buffer, 0, state.Buffer.Length,
                SocketFlags.None,
                ref state.RemoteEP,
                EndReceiveFromCallback,
                state);
        }

        void EndReceiveFromCallback(IAsyncResult iar)
        {
            SocketState state = iar.AsyncState as SocketState;
            Socket socket = state.Socket;
            try
            {
                int byteRead = socket.EndReceiveFrom(iar, ref state.RemoteEP);
                MyCentorl.RecvMessage(state.Buffer);
            }
            catch (Exception e)
            {
                Console.WriteLine("发生异常！异常信息：");
                Console.WriteLine(e.Message);
            }
            finally
            {
                //非常重要：继续异步接收
                socket.BeginReceiveFrom(
                    state.Buffer, 0, state.Buffer.Length,
                    SocketFlags.None,
                    ref state.RemoteEP,
                    EndReceiveFromCallback,
                    state);
            }
        }


        public void SendMsg(byte[] Msg)
        {
            EndPoint remoteEP = new IPEndPoint(IPAddress.Parse(MyCentorl.Ip), MyCentorl.UdpPort);
            socket.SendTo(Msg, remoteEP);
        }
    }
}
