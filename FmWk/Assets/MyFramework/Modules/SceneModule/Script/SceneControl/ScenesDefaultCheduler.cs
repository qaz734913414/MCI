using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyFramework
{
    public class ScenesDefaultCheduler : IScenesChedulerBase
    {
        private SceneLoadingViewComp LoadingView;

        public void StartLoadChanage()
        {
            if (LoadingView == null)
                LoadingView = SceneModel.Instance.GetLoadingViewComp();
            LoadingView.Show();
        }

        public void UpdataProgress(float Progress)
        {
            LoadingView.UpdataProgress(Progress);
        }

        public void EndLoadChanage()
        {
            LoadingView.Hide();
        }
    }
}
