using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class TextVisualizer : MonoBehaviour
{
    public Vector3[] pnts;
    public string[] text;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnDrawGizmos()
    {
        if (pnts == null || text == null)
        {
            //pnts = new Vector3[2];
            //pnts[0] = Vector3.zero;
            //pnts[1] = new Vector3(1, 0, 0);
            return;
        }

        //Debug.Log(pnts.Length);
        for (int i = 0; i < pnts.Length; i++)
        {
            UnityEditor.Handles.Label(transform.position + pnts[i], text[i]);
        }
    }
}
