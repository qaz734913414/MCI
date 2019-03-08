using UnityEngine;

namespace MyFramework
{

    public delegate void MGameObject_Awake();
    public delegate void MGameObject_Start();
    public delegate void MGameObject_Update();
    public delegate void MGameObject_FixedUpdate();
    public delegate void MGameObject_LateUpdate();

    public delegate void MGameObject_OnTriggerEnter2D(Collider2D collision);
    public delegate void MGameObject_OnTriggerStay2D(Collider2D collision);
    public delegate void MGameObject_OnTriggerExit2D(Collider2D collision);
    public delegate void MGameObject_OnTriggerEnter(Collider other);
    public delegate void MGameObject_OnTriggerStay(Collider other);
    public delegate void MGameObject_OnTriggerExit(Collider other);


    public class MGameObject:MonoBehaviour
    {
        public MGameObject_Awake AwakeDelegate;
        public MGameObject_Start StartDelegate;
        public MGameObject_Update UpdateDelegate;
        public MGameObject_FixedUpdate FixedUpdateDelegate;
        public MGameObject_LateUpdate LateUpdateDelegate;
        public MGameObject_OnTriggerEnter2D OnTriggerEnter2DDelegate;
        public MGameObject_OnTriggerStay2D OnTriggerStay2DDelegate;
        public MGameObject_OnTriggerExit2D OnTriggerExit2DDelegate;
        public MGameObject_OnTriggerEnter OnTriggerEnterDelegate;
        public MGameObject_OnTriggerStay OnTriggerStayDelegate;
        public MGameObject_OnTriggerExit OnTriggerExitDelegate;

        private void Awake()
        {
            if (AwakeDelegate != null)
            {
                AwakeDelegate();
            }
        }

        private void Start()
        {
            if (StartDelegate != null)
            {
                StartDelegate();
            }
        }

        private void Update()
        {
            if (UpdateDelegate != null)
            {
                UpdateDelegate();
            }
        }

        private void FixedUpdate()
        {
            if (FixedUpdateDelegate != null)
            {
                FixedUpdateDelegate();
            }
        }

        private void LateUpdate()
        {
            if (LateUpdateDelegate != null)
            {
                LateUpdateDelegate();
            }
        }


        private void OnTriggerEnter2D(Collider2D collision)
        {
            if (OnTriggerEnter2DDelegate != null)
            {
                OnTriggerEnter2DDelegate(collision);
            }
        }

        private void OnTriggerStay2D(Collider2D collision)
        {
            if (OnTriggerStay2DDelegate != null)
            {
                OnTriggerStay2DDelegate(collision);
            }
        }

        private void OnTriggerExit2D(Collider2D collision)
        {
            if (OnTriggerExit2DDelegate != null)
            {
                OnTriggerExit2DDelegate(collision);
            }
        }

        private void OnTriggerEnter(Collider other)
        {
            if (OnTriggerEnterDelegate != null)
            {
                OnTriggerEnterDelegate(other);
            }
        }

        private void OnTriggerStay(Collider other)
        {
            if (OnTriggerStayDelegate != null)
            {
                OnTriggerStayDelegate(other);
            }
        }

        private void OnTriggerExit(Collider other)
        {
            if (OnTriggerExitDelegate != null)
            {
                OnTriggerExitDelegate(other);
            }
        }
    }
}
