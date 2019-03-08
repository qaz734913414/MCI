using UnityEngine;
using System.Collections;
using System.Collections.Generic;


/// <summary>
/// 通用模块组件_协程组件(因为模块都不是继承monobehaver 所以没法直接调用协程，特此通过此组件来完成此功能)
/// </summary>
namespace MyFramework
{
    public class Model_CoroutineComp : ModelCompBase
    {
        #region 框架构造
        public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
        {
            if (CoroutineModel.Instance == null)
            {
                LoggerHelper.Error("CoroutineModel User but No Load");
                return ;
            }
            CoroutineTasks = new List<CoroutineTask>();
            base.Load(_ModelContorl);
            base.LoadEnd();
        }
        #endregion

        /// <summary>
        /// 模块内协程任务列表
        /// </summary>
        protected List<CoroutineTask> CoroutineTasks;

        public CoroutineTask StartCoroutine(IEnumerator coroutine)
        {
            CoroutineTask task = CoroutineModel.Instance.StartCoroutineTask(coroutine);
            task.Finished += TaskFinshed;
            CoroutineTasks.Add(task);
            return task;
        }

        public void StopCoroutine(CoroutineTask task)
        {
            task.Stop();
        }

        public void StopAllCoroutine()
        {
            for (int i = 1; i< CoroutineTasks.Count; i++)
            {
                StopCoroutine(CoroutineTasks[i]);
            }
        }

        private void TaskFinshed(CoroutineTask task,bool IsFinsh)
        {
            if (CoroutineTasks.Contains(task))
            {
                CoroutineTasks.Remove(task);
            }
        }
    }
}
