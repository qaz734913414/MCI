using System;
/// <summary>
/// 计时器管理系统
/// </summary>
namespace MyFramework
{
    public class TimerModel:ManagerContorBase<TimerModel>, IUpdataMode
    {
        private TimerModelDataComp DataComp;
        public override void Load(params object[] _Agr)
        {
            DataComp = AddComp<TimerModelDataComp>();
            base.Load(_Agr);
        }

        public void Update(float time)
        {
            DataComp.Tick();
        }

        #region 添加计数器
        public uint AddTimer(uint start, Action handler)
        {
            return DataComp.AddTimer(start, 0, handler);
        }
        public uint AddTimer(uint start, int interval, Action handler)
        {
            return DataComp.AddTimer(start, interval, handler);
        }
        public uint AddTimer<T>(uint start, int interval, Action<T> handler, T arg1)
        {
            return DataComp.AddTimer<T>(start, interval, handler, arg1);
        }
        public uint AddTimer<T, U>(uint start, int interval, Action<T, U> handler, T arg1, U arg2)
        {
            return DataComp.AddTimer<T, U>(start, interval, handler, arg1, arg2);
        }
        public uint AddTimer<T, U, V>(uint start, int interval, Action<T, U, V> handler, T arg1, U arg2, V arg3)
        {
            return DataComp.AddTimer<T, U, V>(start, interval, handler, arg1, arg2, arg3);
        }
        #endregion

        #region 删除计时器
        public void DelTimer(uint timerId)
        {
            DataComp.DelTimer(timerId);
        }
        #endregion
        public void Reset()
        {
            DataComp.Reset();
        }

    }
}
