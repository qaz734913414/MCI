using UnityEngine;
using System.Collections;
using System.Collections.Generic;
/*
 模块管理器基类
 */
namespace MyFramework
{
    public abstract class ManagerBase : MonoBehaviour 
    {
        protected Dictionary<string, ModelContorlBase> models;
        private bool Lock = false;                              //models 操作锁
        private Dictionary<string, ModelContorlBase> Tmpmodels; //防止models循环中操作队列导致报错
        public Dictionary<string, ModelContorlBase> Models
        {
            get { return models; }
        }

        protected virtual void Init()
        {
            models = new Dictionary<string, ModelContorlBase>();
            Tmpmodels = new Dictionary<string, ModelContorlBase>();
        }

        protected void StartModel(string ModelName, ModelContorlBase _Model) 
        {
            if (!Lock)
            {
                models[ModelName] = _Model;
            }
            else
            {
                Tmpmodels[ModelName] = _Model;
            }
        }

        protected void CloseModel(string ModelName)
        {
            if (!Lock)
            {
                models.Remove(ModelName);
            }
            else
            {
                Tmpmodels.Remove(ModelName);
            }
        }

        protected void Update()
        {
            if (Tmpmodels.Count > 0)
            {
                foreach (var model in Tmpmodels)
                {
                    Models.Add(model.Key, model.Value);
                }
                Tmpmodels.Clear();
            }
            Lock = true;
            foreach (var model in Models)
            {
                if (model.Value is IUpdataMode && model.Value.State == ModelBaseState.Start)
                {
                    ((IUpdataMode)model.Value).Update(Time.deltaTime);
                }
            }
            Lock = false;
        }

        protected void FixedUpdate()
        {
            if (Tmpmodels.Count > 0)
            {
                foreach (var model in Tmpmodels)
                {
                    Models.Add(model.Key, model.Value);
                }
                Tmpmodels.Clear();
            }
            Lock = true;
            foreach (var model in Models)
            {
                if (model.Value is IFixedUpdateMode && model.Value.State == ModelBaseState.Start)
                {
                    ((IFixedUpdateMode)model.Value).FixedUpdate();
                }
            }
            Lock = false;
        }

    }

    public abstract class ManagerBase<M,BaseC> : ManagerBase where M: ManagerBase<M, BaseC> where BaseC : ModelContorlBase,new()
    {
        protected new Dictionary<string, BaseC> Models;
        #region 单例接口
        private static M _instance = null;
        public static M Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = FindObjectOfType(typeof(M)) as M;
                    if (_instance == null)
                    {
                        GameObject obj = new GameObject(typeof(M).Name, typeof(M));
                        _instance = obj.GetComponent<M>() as M;
                        _instance.Init();
                    }
                }
                return _instance;
            }
        }
        #endregion
        public abstract void StartModel<C>(ModelLoadBackCall<C> BackCall = null, params object[] _Agr) where C : BaseC, new();
        public abstract void StartModelForName(string nameSpace,string ModelName, ModelLoadBackCall<BaseC> BackCall = null, params object[] _Agr);
        protected abstract IEnumerator ModelStart<C>(C model,ModelLoadBackCall<C> BackCall, params object[] _Agr) where C : BaseC, new();
        public abstract void CloseModel<C>() where C : BaseC, new();
        public abstract void CloseModelForName(string ModelName);
    }
}