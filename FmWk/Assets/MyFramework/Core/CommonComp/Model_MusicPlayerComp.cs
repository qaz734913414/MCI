using UnityEngine;

namespace MyFramework
{
    public class Model_MusicPlayerComp : ModelCompBase
    {
        #region 框架构造
        public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
        {
            base.Load(_ModelContorl);
            base.LoadEnd();
        }
        #endregion

        public void PlayBackMusic(string MusicName)
        {
            AudioClip Music = MyCentorl.LoadAsset<AudioClip>("Sound", MusicName);
            PlayBackMusic(Music);
        }

        public void PlayBackMusic(AudioClip Music)
        {
            SoundPlayerModel.Instance.PlayMusic(MyCentorl.ModelName, Music, true);
        }

        public void PlayEffetcMusic(string MusicName)
        {
            AudioClip Music = MyCentorl.LoadAsset<AudioClip>("Sound", MusicName);
            PlayBackMusic(Music);
        }
        public void PlayEffetcMusic(AudioClip Music)
        {
            SoundPlayerModel.Instance.PlayMusic(MyCentorl.ModelName, Music, false);
        }
    }
}
