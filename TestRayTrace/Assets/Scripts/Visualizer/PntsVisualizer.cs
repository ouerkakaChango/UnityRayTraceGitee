using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PntsVisualizer : MonoBehaviour
{
    List<Vector3> pnts = new List<Vector3>();
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    public void Clear()
    {
        pnts.Clear();
    }

    public void Add(Vector3 p)
    {
        pnts.Add(p);
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        for (int i = 0; i < pnts.Count; i++)
        {
            //Gizmos.DrawWireSphere(pnts[i], 0.01f);
            Gizmos.DrawCube(pnts[i], 0.01f * Vector3.one);
            //Gizmos.DrawSphere(pnts[i], 0.01f);
        }
    }
}
