using System;

namespace MyFramework
{
    /// <summary>
    /// 定时器实体
    /// </summary>
    public abstract class TimerDataBase
    {
        /// <summary>
        /// 计时器服务模块
        /// </summary>
        public ModelContorlBase TargetModel;
        /// <summary>
        /// 计时器ID
        /// </summary>
        public uint NTimerId { get; set; }
        /// <summary>
        /// 时间间隔
        /// </summary>
        public int NInterval { get; set; }
        public ulong UnNextTick { get; set; }
        public abstract Delegate Action { get; set; }
        public abstract void DoAction();
    }

    /// <summary>
    /// 无参数定时器实体
    /// </summary>
    internal class TimerData : TimerDataBase
    {
        private Action m_action;

        public override Delegate Action
        {
            get { return m_action; }
            set { m_action = value as Action; }
        }

        public override void DoAction()
        {
            m_action();
        }
    }

    /// <summary>
    /// 1个参数定时器实体
    /// </summary>
    /// <typeparam name="T">参数1</typeparam>
    internal class TimerData<T> : TimerDataBase
    {
        private Action<T> m_action;

        public override Delegate Action
        {
            get { return m_action; }
            set { m_action = value as Action<T>; }
        }

        private T m_arg1;

        public T Arg1
        {
            get { return m_arg1; }
            set { m_arg1 = value; }
        }

        public override void DoAction()
        {
            m_action(m_arg1);
        }
    }

    /// <summary>
    /// 2个参数定时器实体
    /// </summary>
    /// <typeparam name="T">参数1</typeparam>
    /// <typeparam name="U">参数2</typeparam>
    internal class TimerData<T, U> : TimerDataBase
    {
        private Action<T, U> m_action;

        public override Delegate Action
        {
            get { return m_action; }
            set { m_action = value as Action<T, U>; }
        }

        private T m_arg1;

        public T Arg1
        {
            get { return m_arg1; }
            set { m_arg1 = value; }
        }

        private U m_arg2;

        public U Arg2
        {
            get { return m_arg2; }
            set { m_arg2 = value; }
        }

        public override void DoAction()
        {
            m_action(m_arg1, m_arg2);
        }
    }

    /// <summary>
    /// 3个参数定时器实体
    /// </summary>
    /// <typeparam name="T">参数1</typeparam>
    /// <typeparam name="U">参数2</typeparam>
    /// <typeparam name="V">参数3</typeparam>
    internal class TimerData<T, U, V> : TimerDataBase
    {
        private Action<T, U, V> m_action;

        public override Delegate Action
        {
            get { return m_action; }
            set { m_action = value as Action<T, U, V>; }
        }

        private T m_arg1;

        public T Arg1
        {
            get { return m_arg1; }
            set { m_arg1 = value; }
        }

        private U m_arg2;

        public U Arg2
        {
            get { return m_arg2; }
            set { m_arg2 = value; }
        }

        private V m_arg3;

        public V Arg3
        {
            get { return m_arg3; }
            set { m_arg3 = value; }
        }

        public override void DoAction()
        {
            m_action(m_arg1, m_arg2, m_arg3);
        }
    }
}
