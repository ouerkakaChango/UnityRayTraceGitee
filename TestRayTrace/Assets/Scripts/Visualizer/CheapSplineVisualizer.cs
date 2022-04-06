using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Spline;

public class CheapSplineVisualizer : MonoBehaviour
{
    CheapSpline spline = null;
    public float scale = 1.0f;
    [Range(0.0f,1.0f)]
    public float t = 0;
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
        if(!spline)
        {
            spline = GetComponent<CheapSpline>();
        }
        Gizmos.color = Color.red;
        for (int i = 0; i < spline.keyPnts.Count; i++)
        {
            Gizmos.DrawCube(spline.keyPnts[i], 0.1f * scale * Vector3.one);
        }

        Gizmos.color = Color.yellow;
        var p = spline.GetPnt(t);
        Gizmos.DrawCube(p, 0.1f * scale * Vector3.one);
    }
}
