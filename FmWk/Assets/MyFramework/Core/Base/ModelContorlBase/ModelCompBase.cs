using System;

/*
 作者 : liwei1dao
 文件 : ModelContorlBase.cs
 描述 : 框架模块组件基类
 修改 : 模块组件
*/
namespace MyFramework
{
    public enum ModelCompBaseState
    {
        Close,          //关闭状态
        Loading,        //加载中状态
        LoadEnd,        //加载完成状态
        Start,          //启动状态
    }

    /// <summary>
    /// 模块组件基类
    /// </summary>
    public abstract class ModelCompBase
    {
        protected ModelContorlBase MyCentorl;
        public ModelCompBaseState State = ModelCompBaseState.Close;
        public virtual void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
        {
            MyCentorl = _ModelContorl;
            State = ModelCompBaseState.Loading;
        }
        protected virtual void LoadEnd()
        {
            State = ModelCompBaseState.LoadEnd;
            MyCentorl.LoadEnd();
        }
        public virtual void Start(params object[] _Agr)
        {
            State = ModelCompBaseState.Start;
        }
        public virtual void Close()
        {
            MyCentorl = null;
            State = ModelCompBaseState.Close;
        }

        /// <summary>
        /// Inspector 属性界面
        /// </summary>
        public virtual void ShowInspector()
        {

        }
    }

    public abstract class ModelCompBase<C> : ModelCompBase where C: ModelContorlBase, new()
    {
        protected new C MyCentorl;

        public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
        {
            MyCentorl = _ModelContorl as C;
            base.Load(_ModelContorl, _Agr);
        }

        protected override void LoadEnd()
        {
            base.LoadEnd();
        }

        public override void Start(params object[] _Agr)
        {
            base.Start(_Agr);
        }                                                  
        public override void Close()
        {
            base.Close();
        }                                   
    }
}
