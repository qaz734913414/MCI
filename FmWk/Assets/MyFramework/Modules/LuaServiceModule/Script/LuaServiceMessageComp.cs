using UnityEngine;
using System.Collections;
using System.Collections.Generic;


namespace MyFramework
{
    public class LuaServiceMessageComp : ModelCompBase<LuaServiceModel>
    {
        private Queue<CSMessage> ReceiveMessageQueue;           //消息接收队列
        private bool IsDealMesageing;                           //消息处理中
        public override void Load(ModelContorlBase _ModelContorl, params object[] _Agr)
        {
            ReceiveMessageQueue = new Queue<CSMessage>();
            base.Load(_ModelContorl, _Agr);
            LoadEnd();
        }

        public void ReceiveMessage(CSMessage Msg)
        {
            lock (ReceiveMessageQueue)
            {
                ReceiveMessageQueue.Enqueue(Msg);
                if (!IsDealMesageing)
                {
                    MyCentorl.VP(0, () =>
                    {
                        IsDealMesageing = true;
                        MyCentorl.StartCoroutine(DealMesageCoroutine());
                    });
                }
            }
        }

        /// <summary>
        /// 一帧处理一条消息
        /// </summary>
        /// <returns></returns>
        private IEnumerator DealMesageCoroutine()
        {
            while (ReceiveMessageQueue.Count > 0)
            {
                MyCentorl.DealMessage(ReceiveMessageQueue.Dequeue());
                yield return new WaitForEndOfFrame();
            }
            IsDealMesageing = false;
        }

    }
}
