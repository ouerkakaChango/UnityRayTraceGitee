using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public delegate void InputHandler();

public class KeyboardInputer : MonoBehaviour
{
    public Dictionary<string, InputHandler> keyDic = new Dictionary<string, InputHandler>();
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        var keyArr = keyDic.Keys.ToArray();
        for (int i=0;i< keyArr.Length; i++)
        {
            var key = keyArr[i];
            if (Input.GetKeyDown(key))
            {
                keyDic[key]();
            }
        }
    }

    //###############################################
}
