using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace XCGame
{
    public enum TriggerEnterOnceEvent
    {
        PlayerEnter,
    }

    public enum TriggerAction
    {
        SetDynamicVal,
        KeyBind_q,
    }
    public class GeneralTrigger : MonoBehaviour
    {
        public List<TriggerEnterOnceEvent> enterOnceEvents = new List<TriggerEnterOnceEvent>();
        public List<TriggerAction> actions = new List<TriggerAction>();
        public List<float> f_params = new List<float>();
        public List<string> str_params = new List<string>();
        // Start is called before the first frame update
        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {

        }

        private void OnTriggerEnter(Collider other)
        {
            for (int i=0;i<enterOnceEvents.Count;i++)
            {
                bool condition = false;
                if(enterOnceEvents[i] == TriggerEnterOnceEvent.PlayerEnter)
                {
                    condition = IsPlayerEnter(other);
                }
                if(condition)
                {
                    for (int i1 = 0; i1 < actions.Count; i1++)
                    {
                        DoAction(other, i1);
                    }
                }
            }
            enterOnceEvents.Clear();
        }

        //###################################################################################
        bool IsPlayerEnter(Collider other)
        {
            return other.gameObject.GetComponent<SDFGameSceneTrace>() != null;
        }

        void DoAction(Collider other, int inx)
        {
            if(actions[inx]==TriggerAction.SetDynamicVal)
            {
                //Debug.Log("set dynamic");
                DynamicValSys dyValSys = other.gameObject.GetComponent<AutoCS>().dyValSys;
                dyValSys.Set(str_params[inx], f_params[inx]);
            }
            else if (actions[inx] == TriggerAction.KeyBind_q)
            {
                //???
                other.gameObject.GetComponent<SDFGameSceneTrace>().AddKeybind_q();
            }
        }
    }

}