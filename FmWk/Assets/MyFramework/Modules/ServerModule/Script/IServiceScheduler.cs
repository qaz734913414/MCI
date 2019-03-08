using MyFramework;

namespace MyFramework
{
    /// <summary>
    /// 消息分发处理
    /// </summary>
    public interface IServiceSchedulerBase 
    {
        /// <summary>
        /// 消息处理
        /// </summary>
        /// <param name="MsgId"></param>
        /// <param name="msg"></param>
        void DealMessage(CSMessage msg);
    }
}
