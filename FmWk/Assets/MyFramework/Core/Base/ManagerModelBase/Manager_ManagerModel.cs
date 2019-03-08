using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;

/*
管理器:管理管理器模块
Init 管理器装配初始化借口
LoadModel 加载对应管理器模块接口
CloseModel 卸载对应管理器模块接口
*/
namespace MyFramework
{
    public class Manager_ManagerModel : ManagerBase<Manager_ManagerModel, ManagerContorBase>
    {
        protected override void Init()
        {
            DontDestroyOnLoad(gameObject);
            Models = new Dictionary<string, ManagerContorBase>();
            base.Init();
        }
        public override void StartModel<C>(ModelLoadBackCall<C> BackCall = null, params object[] _Agr)
        {
            string ModelName = typeof(C).Name;
            if (!Models.ContainsKey(ModelName))
            {
                Models[ModelName] = new C();
                Models[ModelName].ModelName = ModelName;
                base.StartModel(ModelName, Models[ModelName]);
                Models[ModelName].Load<C>((model)=> {
                    StartCoroutine(ModelStart<C>(model, BackCall, _Agr));
                }, _Agr);
            }
            else
            {
                LoggerHelper.Error("This Model Already Load:" + typeof(C).Name);
            }
        }
        public override void StartModelForName(string nameSpace, string ModelName, ModelLoadBackCall<ManagerContorBase> BackCall = null, params object[] _Agr)
        {
            if (!Models.ContainsKey(ModelName))
            {
                Models[ModelName] = Assembly.GetExecutingAssembly().CreateInstance(nameSpace + "." + ModelName, true, System.Reflection.BindingFlags.Default, null, null, null, null) as ManagerContorBase;
                Models[ModelName].ModelName = ModelName;
                base.StartModel(ModelName, Models[ModelName]);
                Models[ModelName].Load<ManagerContorBase>((model) => {
                    StartCoroutine(ModelStart<ManagerContorBase>(model, BackCall, _Agr));
                }, _Agr);
            }
            else
            {
                LoggerHelper.Error("This Model Already Load:" + ModelName);
            }
        }

        protected override IEnumerator ModelStart<C>(C model, ModelLoadBackCall<C> BackCall, params object[] _Agr)
        {
            yield return new WaitForEndOfFrame();
            model.Start(_Agr);
            if (BackCall != null)
                BackCall(model);
        }
        public override void CloseModel<C>()
        {
            string ModelName = typeof(C).Name;
            if (Models.ContainsKey(ModelName))
            {
                Models[ModelName].Close();
                Models.Remove(ModelName);
                base.CloseModel(ModelName);
            }
            else
            {
                LoggerHelper.Error("This Model Already Close:" + typeof(C).Name);
            }
        }
        public override void CloseModelForName(string ModelName)
        {
            if (Models.ContainsKey(ModelName))
            {
                Models[ModelName].Close();
                Models.Remove(ModelName);
                base.CloseModel(ModelName);
            }
            else
            {
                LoggerHelper.Error("This Model Already Close:" + ModelName);
            }
        }
    }
}
