using System.Collections;

namespace MyFramework
{
    public abstract class Model_BaseSceneComp<C> : ModelCompBase<C>, ISceneLoadCompBase where C : ModelContorlBase, ISceneMode, new()
    {
        protected float Process;

        public float GetProcess()
        {
            return Process;
        }

        public abstract string GetSceneName();

        public abstract IEnumerator LoadScene();

        public abstract IEnumerator UnloadScene();
    }
}
