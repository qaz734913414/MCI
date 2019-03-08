using System;
using System.Collections;

namespace MyFramework
{
    /// <summary>
    /// 场景控制类接口
    /// </summary>
    public interface ISceneLoadCompBase
    {
        /// <summary>
        ///获取场景切换进入
        /// </summary>
        /// <returns></returns>
        float GetProcess();

        /// <summary>
        /// 获取场景名称
        /// </summary>
        /// <returns></returns>
        string GetSceneName();

        /// <summary>
        /// 场景加载
        /// </summary>
        IEnumerator LoadScene();

        /// <summary>
        /// 场景卸载
        /// </summary>
        IEnumerator UnloadScene();
    }
}
