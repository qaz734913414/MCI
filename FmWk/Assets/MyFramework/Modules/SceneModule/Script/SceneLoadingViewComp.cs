using UnityEngine.UI;

namespace MyFramework
{
    public class SceneLoadingViewComp : Model_BaseViewComp
    {
        private Slider LoadProgress;

        public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
        {
            ShowLevel = UILevel.HightUI;
            base.Load(_ModelContorl, "LoadingView");
            LoadProgress = UIGameobject.OnSubmit<Slider>("LoadProgress");
        }

        public void UpdataProgress(float _Progress)
        {
            LoadProgress.value = _Progress;
        }
    }
}
