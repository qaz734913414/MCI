using MyFramework;


public class LoginModule : ManagerContorBase<LoginModule>
{

    public LoginMessageComp MessageComp;
    public LoginViewComp LoginViewComp;
    public override void Load(params object[] _Agr)
    {
        ResourceComp = AddComp<Model_ResourceComp>();
        MessageComp = AddComp<LoginMessageComp>();
        LoginViewComp = AddComp<LoginViewComp>();
        base.Load(_Agr);
    }



}

