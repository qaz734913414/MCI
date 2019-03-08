using System;
using System.Diagnostics;

namespace MyFramework
{ 
    public class TimerModelDataComp : ModelCompBase<TimerModel>
    {
        #region 框架构造
        public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
        {
            m_queue = new KeyedPriorityQueue<uint, TimerDataBase, ulong>();
            m_stopWatch = new Stopwatch();
            IsQueue = false;
            base.Load(_ModelContorl);
            base.LoadEnd();
        }
        #endregion
        private uint m_nNextTimerId;
        private uint m_unTick;
        private KeyedPriorityQueue<uint, TimerDataBase, ulong> m_queue;      //计时器数据池
        private Stopwatch m_stopWatch;
        private readonly object m_queueLock = new object();
        private bool IsQueue = false;

        #region 添加计数器
        /// <summary>
        /// 添加定时对象
        /// </summary>
        /// <returns>定时对象Id</returns>
        public uint AddTimer(TimerDataBase p)
        {
            lock (m_queueLock)
                m_queue.Enqueue(p.NTimerId, p, p.UnNextTick);
            return p.NTimerId;
        }

        /// <summary>
        /// 添加定时对象 0个参数
        /// </summary>
        /// <param name="start">延迟启动时间。（毫秒）</param>
        /// <param name="interval">重复间隔，为零不重复。（毫秒）</param>
        /// <param name="handler">定时处理方法</param>
        /// <returns>定时对象Id</returns>
        public uint AddTimer(uint start, int interval, Action handler)
        {
            //起始时间会有一个tick的误差,tick精度越高,误差越低
            var p = GetTimerData(new TimerData(), start, interval);
            p.Action = handler;
            return AddTimer(p);
        }

        /// <summary>
        /// 添加定时对象 1个参数
        /// </summary>
        /// <typeparam name="T">参数类型1</typeparam>
        /// <param name="start">延迟启动时间。（毫秒）</param>
        /// <param name="interval">重复间隔，为零不重复。（毫秒）</param>
        /// <param name="handler">定时处理方法</param>
        /// <param name="arg1">参数1</param>
        /// <returns>定时对象Id</returns>
        public uint AddTimer<T>(uint start, int interval, Action<T> handler, T arg1)
        {
            var p = GetTimerData(new TimerData<T>(), start, interval);
            p.Action = handler;
            p.Arg1 = arg1;
            return AddTimer(p);
        }

        /// <summary>
        /// 添加定时对象 2个参数
        /// </summary>
        /// <typeparam name="T">参数类型1</typeparam>
        /// <typeparam name="U">参数类型2</typeparam>
        /// <param name="start">延迟启动时间。（毫秒）</param>
        /// <param name="interval">重复间隔，为零不重复。（毫秒）</param>
        /// <param name="handler">定时处理方法</param>
        /// <param name="arg1">参数1</param>
        /// <param name="arg2">参数2</param>
        /// <returns>定时对象Id</returns>
        public uint AddTimer<T, U>(uint start, int interval, Action<T, U> handler, T arg1, U arg2)
        {
            var p = GetTimerData(new TimerData<T, U>(), start, interval);
            p.Action = handler;
            p.Arg1 = arg1;
            p.Arg2 = arg2;
            return AddTimer(p);
        }

        /// <summary>
        /// 添加定时对象 3个参数
        /// </summary>
        /// <typeparam name="T">参数类型1</typeparam>
        /// <typeparam name="U">参数类型2</typeparam>
        /// <typeparam name="V">参数类型3</typeparam>
        /// <param name="start">延迟启动时间。（毫秒）</param>
        /// <param name="interval">重复间隔，为零不重复。（毫秒）</param>
        /// <param name="handler">定时处理方法</param>
        /// <param name="arg1">参数1</param>
        /// <param name="arg2">参数2</param>
        /// <param name="arg3">参数3</param>
        /// <returns>定时对象Id</returns>
        public uint AddTimer<T, U, V>(uint start, int interval, Action<T, U, V> handler, T arg1, U arg2, V arg3)
        {
            var p = GetTimerData(new TimerData<T, U, V>(), start, interval);
            p.Action = handler;
            p.Arg1 = arg1;
            p.Arg2 = arg2;
            p.Arg3 = arg3;
            return AddTimer(p);
        }
        #endregion

        #region 删除计时器
        /// <summary>
        /// 删除定时对象
        /// </summary>
        /// <param name="timerId">定时对象Id</param>
        public void DelTimer(uint timerId)
        {
            lock (m_queueLock)
                m_queue.Remove(timerId);
        }
        #endregion

        #region 触发计时器
        /// <summary>
        /// 周期调用触发任务
        /// </summary>
        public void Tick()
        {
            if (!IsQueue) return;
            m_unTick += (uint)m_stopWatch.ElapsedMilliseconds;
            m_stopWatch.Reset();
            m_stopWatch.Start();

            while (m_queue.Count != 0)
            {
                TimerDataBase p;
                lock (m_queueLock)
                    p = m_queue.Peek();
                if (m_unTick < p.UnNextTick)
                {
                    break;
                }
                lock (m_queueLock)
                    m_queue.Dequeue();
                if (p.NInterval > 0)
                {
                    p.UnNextTick += (ulong)p.NInterval;
                    lock (m_queueLock)
                        m_queue.Enqueue(p.NTimerId, p, p.UnNextTick);
                    p.DoAction();
                }
                else
                {
                    p.DoAction();
                }
            }
        }
        #endregion

        /// <summary>
        /// 重置定时触发器
        /// </summary>
        public void Reset()
        {
            m_unTick = 0;
            m_nNextTimerId = 0;
            lock (m_queueLock)
                while (m_queue.Count != 0)
                    m_queue.Dequeue();
        }

        private T GetTimerData<T>(T p, uint start, int interval) where T : TimerDataBase
        {
            p.NInterval = interval;
            p.NTimerId = ++m_nNextTimerId;
            p.UnNextTick = m_unTick + 1 + start;
            IsQueue = true;
            return p;
        }
    }
}
