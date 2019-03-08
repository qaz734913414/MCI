using MyFramework;
using UnityEngine;
using UnityEngine.UI;

public class LoginViewComp : Model_BaseViewComp<LoginModule>
{
    private Image Image;
    private Button TestButt;
    public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
    {
        base.Load(_ModelContorl, "LoginViewComp");
        Image = UIGameobject.OnSubmit<Image>("Image");
        Image.sprite = MyCentorl.LoadAsset<Sprite>("Image", "zi_zhdl");
        TestButt = UIGameobject.OnSubmit<Button>("TestButt");
        TestButt.onClick.AddListener(TestButtClick);

    }

    private void TestButtClick()
    {
        MyCentorl.MessageComp.SendRegisterTestAcountReq("liwei1dao","111111");
        LoggerHelper.Debug("发送注册测试帐号的消息");
    }

}