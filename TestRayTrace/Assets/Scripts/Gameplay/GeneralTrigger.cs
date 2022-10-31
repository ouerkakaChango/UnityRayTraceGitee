using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace XCGame
{
    public enum TriggerEnterOnceEvent
    {
        PlayerEnter,
    }

    public enum TriggerSinceStartEvent
    {
        Timeup,
    }

    public enum TriggerAction
    {
        SetDynamicVal,
        KeyBind_q,
        EnableNextLevelDoor,
        GotoNextLevel,
        DebugLogMessage,
        TestKeyBind_qe,
    }
    public class GeneralTrigger : MonoBehaviour
    {
        public List<TriggerEnterOnceEvent> enterOnceEvents = new List<TriggerEnterOnceEvent>();
        public List<TriggerSinceStartEvent> sinceStartEvents = new List<TriggerSinceStartEvent>();

        public List<TriggerAction> actions = new List<TriggerAction>();
        public List<float> f_params = new List<float>();
        public List<string> str_params = new List<string>();

        float start_t;

        // Start is called before the first frame update
        void Start()
        {
            start_t = Time.timeSinceLevelLoad;
        }

        // Update is called once per frame
        void Update()
        {
            float t = Time.timeSinceLevelLoad - start_t;
            for(int i=0;i<sinceStartEvents.Count;i++)
            {
                bool condition = false;
                if(sinceStartEvents[i] == TriggerSinceStartEvent.Timeup)
                {
                    condition = t >= f_params[0];
                }
                if (condition)
                {
                    for (int i1 = 0; i1 < actions.Count; i1++)
                    {
                        DoAction(i1);
                    }
                }
            }
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
                        DoAction(i1, other);
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

        void DoAction(int inx, Collider other=null)
        {
            if(actions[inx]==TriggerAction.SetDynamicVal)
            {
                //Debug.Log("set dynamic");
                DynamicValSys dyValSys = other.gameObject.GetComponent<AutoCS>().dyValSys;
                dyValSys.Set(str_params[inx], f_params[inx]);
            }
            else if (actions[inx] == TriggerAction.KeyBind_q)
            {
                //!!!
                other.gameObject.GetComponent<SDFGameSceneTrace>().AddKeybind_q();
            }
            else if(actions[inx] == TriggerAction.EnableNextLevelDoor)
            {
                //!!!
                var bakerMgr = Camera.main.gameObject.GetComponent<AutoCS>().bakerMgr;
                var gameSys = bakerMgr.gameObject.GetComponent<GameSceneSystem>();
                var boxColi = gameSys.nextLevelObj.GetComponent<BoxCollider>();
                boxColi.enabled = true;
            }
            else if (actions[inx] == TriggerAction.GotoNextLevel)
            {
                //???
                //SceneManager.LoadScene("TransferScene");
                var nextName = str_params[0];
                SceneManager.LoadScene(nextName);
            }
            else if (actions[inx] == TriggerAction.DebugLogMessage)
            {
                //Debug.Log("General Trigger: " + str_params[0]);
            }
        }
    }

}