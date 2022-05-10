using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NearestPntVisualizer : MonoBehaviour
{
    public float pntScale = 1.0f;
    public Vector3 target,pnt;
    public float step = 0.1f;
    public int loopNum = 1;
    public bool bCalculated = false;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawCube(target, pntScale * 0.01f * Vector3.one);
        if(bCalculated)
        {
            Gizmos.color = Color.blue;
            UnityEditor.Handles.Label(target+ pntScale * new Vector3(0.05f,0,0), (pnt-target).magnitude.ToString());
            Gizmos.DrawCube(pnt, pntScale * 0.01f * Vector3.one);
            Gizmos.DrawLine(pnt, target);
        }
    }

    //#############################################
    public void CosFBM()
    {
        var fbm = GetComponent<CosFBM>();
        if(!fbm)
        {
            return;
        }
        pnt = fbm.NearestPoint(target, loopNum, step);
        bCalculated = true;
    }
}
