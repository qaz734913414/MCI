using MyFramework;
using UnityEngine;
public class AppMain : Main
{
    private void Awake()
    {
        SetConfig();
        StartApp();
    }

    protected override void SetConfig()
    {
        base.SetConfig();
    }

    protected override void StartApp()
    {
        base.StartApp();
        Manager_ManagerModel.Instance.StartModel<LuaManagerModel>();
        //Manager_ManagerModel.Instance.StartModel<TimerModel>();
        //Manager_ManagerModel.Instance.StartModel<CoroutineModel>();
        //Manager_ManagerModel.Instance.StartModel<ServiceModel>(null, "127.0.0.1", 9090);
        //Manager_ManagerModel.Instance.StartModel<ViewManagerModel>(null,new Vector2(1920,1080),1.0f);
        //Manager_ManagerModel.Instance.StartModel<LoginModule>();
    }
}
