using MyFramework;
using Google.Protobuf;


public class LoginMessageComp : ModelCompBase<LoginModule>, IServiceSchedulerBase
{
    public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
    {
        base.Load(_ModelContorl, _Agr);
        ServiceModel.Instance.RegisterScheduler(1, this);
        LoadEnd();
    }

    //--------------------------------------------------------------发送消息----------------------------------------------------------------------
    /// <summary>
    /// 发送注册测试账号
    /// </summary>
    /// <param name="_Account"></param>
    /// <param name="_Password"></param>
    public void SendRegisterTestAcountReq(string _Account,string _Password)
    {
        Login.RegisterTestAcountReq msg = new Login.RegisterTestAcountReq()
        {
            Account = "liwei1dao",
            Password = "li13451234",
        };
        CSMessage cmsg = new CSMessage();
        cmsg.WriteMsg(1, 1, msg.ToByteArray());
        ServiceModel.Instance.SendMessage(cmsg);
    }

    /// <summary>
    /// 发送登陆测试账号的协议
    /// </summary>
    /// <param name="_Account"></param>
    /// <param name="_Password"></param>
    public void SendLoginTestAcountReq(string _Account, string _Password)
    {
        Login.LoginTestAcountReq msg = new Login.LoginTestAcountReq()
        {
            Account = _Account,
            Password = _Password,
        };
        CSMessage cmsg = new CSMessage();
        cmsg.WriteMsg(1, 1, msg.ToByteArray());
        ServiceModel.Instance.SendMessage(cmsg);
    }
    //-------------------------------------------------------------接收消息------------------------------------------------------------------------

    public void DealMessage(CSMessage msg)
    {
        LoggerHelper.Debug("收到服务器消息", msg.Head.MsgId);
        switch (msg.Head.MsgId)
        {
            case 2: //注册测试账号回应
                RegisterTestAcountRes(msg.Msg);
                break;
            case 4:
                LoginTestAcountRes(msg.Msg);
                break;
        }
    }

    //收到服务器测试注册回应
    private void RegisterTestAcountRes(byte[] _buffer)
    {
        Login.RegisterTestAcountRes msg2 = Login.RegisterTestAcountRes.Parser.ParseFrom(_buffer);
        LoggerHelper.Debug("收到用户注册测试账号回应消息" + msg2.Error);
    }

    //收到服务器测试账号登陆回应
    private void LoginTestAcountRes(byte[] _buffer)
    {
        Login.RegisterTestAcountRes msg2 = Login.RegisterTestAcountRes.Parser.ParseFrom(_buffer);
        LoggerHelper.Debug("收到用户登陆测试账号回应消息" + msg2.Error);
    }
}


