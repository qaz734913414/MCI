using System;
using UnityEngine;
using System.Collections;

namespace MyFramework
{
    public class CoroutineModel : ManagerContorBase<CoroutineModel>
    {
        private CoroutineModelDataComp DataComp;

        public override void Load(params object[] _Agr)
        {
            DataComp = AddComp<CoroutineModelDataComp>();
            base.Load(_Agr);
        }

        public CoroutineTask StartCoroutineTask(IEnumerator coroutine)
        {
           return DataComp.StartCoroutine(coroutine);
        }

        public void StartTask(CoroutineTask Task)
        {
            Manager_ManagerModel.Instance.StartCoroutine(Task.CallWrapper());
        }
    }
}
