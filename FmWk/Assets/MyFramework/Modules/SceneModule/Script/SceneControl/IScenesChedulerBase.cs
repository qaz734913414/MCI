namespace MyFramework
{
    /// <summary>
    /// 场景调度器
    /// </summary>
    public interface IScenesChedulerBase
    {
        void StartLoadChanage();
        void UpdataProgress(float Progress);
        void EndLoadChanage();
    }
}
