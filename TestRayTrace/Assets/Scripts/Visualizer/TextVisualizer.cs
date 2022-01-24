using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class TextVisualizer : MonoBehaviour
{
     List<Vector3> pnts = new List<Vector3>();
     List<string> texts = new List<string>();
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
        for (int i = 0; i < pnts.Count; i++)
        {
            UnityEditor.Handles.Label(transform.position + pnts[i], texts[i]);
        }
    }

    public void Clear()
    {
        pnts.Clear();
        texts.Clear();
    }

    public void Add(Vector3 pos, string text)
    {
        pnts.Add(pos);
        texts.Add(text);
    }
}
