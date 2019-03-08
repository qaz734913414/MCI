using System;
using System.Collections;
using System.Collections.Generic;

namespace MyFramework
{
    public class CoroutineModelDataComp : ModelCompBase<CoroutineModel>
    {
        #region 框架构造
        public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
        {
            AllTask = new List<CoroutineTask>();
            base.Load(_ModelContorl);
            base.LoadEnd();
        }
        #endregion
        private List<CoroutineTask> AllTask;

        public CoroutineTask StartCoroutine(IEnumerator coroutine)
        {
            CoroutineTask task = new CoroutineTask(coroutine);
            task.Finished += TaskFinished;
            AllTask.Add(task);
            MyCentorl.StartTask(task);
            return task;
        }

        /// <summary>
        ///  任务完成通知
        /// </summary>
        public void TaskFinished(CoroutineTask Task,bool IsFinish)
        {
            AllTask.Remove(Task);
        }

    }
}