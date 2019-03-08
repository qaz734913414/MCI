using System;
using System.Collections.Generic;

namespace MyFramework
{
    public abstract class BinaryHeapValue<T> : IComparable<T> where T : BinaryHeapValue<T>
    {
        public int pos;             //二叉树的所在位置

        public virtual int CompareTo(T other)
        {
            return 0;
        }
    }
    /// <summary>
    /// 二叉树
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class BinaryHeap<T> where T : BinaryHeapValue<T>
    {
        private List<T> heap;
        private T placeHolder;
        private int size;

        public BinaryHeap()
        {
            heap = new List<T>();
            placeHolder = default(T);
            heap.Add(default(T));
        }

        #region 属性
        /// <summary>
        /// 数据长度
        /// </summary>
        public int Count
        {
            get
            {
                return this.size;
            }
        }
        #endregion

        /// <summary>
        /// 清除
        /// </summary>
        public void Clear()
        {
            this.heap.Clear();
            this.size = 0;
        }

        #region 插入数据
        public void Enqueue(T value)
        {
            T local = (this.size > 0) ? this.heap[1] : default(T);
            int num = ++this.size;
            int num2 = num / 2;
            if (num == this.heap.Count)
            {
                this.heap.Add(this.placeHolder);
            }
            while ((num > 1) && this.IsHigher(value, this.heap[num2]))
            {
                this.heap[num] = this.heap[num2];
                num = num2;
                num2 = num / 2;
                this.heap[num].pos = num;
            }
            this.heap[num] = value;
            this.heap[num].pos = num;
        }
        #endregion

        #region 数据出列
        /// <summary>
        ///  移除并返回位于 BinaryHeap 开始处的对象。
        /// </summary>
        /// <returns></returns>
        public T Dequeue()
        {
            T local = (this.size < 1) ? default(T) : this.DequeueImpl();
            return local;
        }
        /// <summary>
        /// 提取堆数据
        /// </summary>
        /// <returns></returns>
        private T DequeueImpl()
        {
            T local = this.heap[1];
            this.heap[1] = this.heap[this.size];
            this.heap[this.size--] = this.placeHolder;
            this.Heapify(1);
            return local;
        }
        #endregion

        #region 数据重洗
        public void Adjust(int pos)
        {
            Heapify(pos);
        }
        #endregion

        #region 二叉树操作
        /// <summary>
        /// 交换数据位置
        /// </summary>
        /// <param name="i"></param>
        /// <param name="j"></param>
        private void Swap(int i, int j)
        {
            T node = this.heap[i];
            this.heap[i] = this.heap[j];
            this.heap[i].pos = i;
            this.heap[j] = node;
            this.heap[j].pos = j;
        }

        /// <summary>
        /// 判断 p2 是否更大
        /// </summary>
        /// <param name="p1"></param>
        /// <param name="p2"></param>
        /// <returns></returns>
        protected virtual bool IsHigher(T p1, T p2)
        {
            return (p1.CompareTo(p2) < 1);
        }

        /// <summary>
        /// 重洗二叉树
        /// </summary>
        /// <param name="i"></param>
        private void Heapify(int i)
        {
            int num = 2 * i;
            int num2 = num + 1;
            int j = i;
            if ((num <= this.size) && this.IsHigher(this.heap[num], this.heap[i]))
            {
                j = num;
            }
            if ((num2 <= this.size) && this.IsHigher(this.heap[num2], this.heap[j]))
            {
                j = num2;
            }
            if (j != i)
            {
                this.Swap(i, j);
                this.Heapify(j);
            }
        }
        #endregion

    }

}
