using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatCompareVisualizer : MonoBehaviour
{
    public Vector3 delta = new Vector3(0, 0, 1);
    public Vector3 spaceAB = new Vector3(0, -1.5f, 0);

    public GameObject objA;
    public GameObject objB;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void GenerateMesh(ref GameObject obj)
    {
        var mf = obj.GetComponent<MeshFilter>();
        if (mf == null)
        {
            mf = obj.AddComponent<MeshFilter>();
        }

        mf.sharedMesh = objA.GetComponent<MeshFilter>().sharedMesh;

        var mr = obj.GetComponent<MeshRenderer>();
        if (mr == null)
        {
            mr = obj.AddComponent<MeshRenderer>();
        }
    }

    void SetMaterial(ref GameObject obj, GameObject temlateObj)
    {
        var template = temlateObj.GetComponent<MeshRenderer>().sharedMaterial;
        var shader = template.shader;
        obj.GetComponent<MeshRenderer>().sharedMaterial = new Material(shader);
    }

    void SetFloatParam(ref GameObject obj, string name, float val)
    {
        obj.GetComponent<MeshRenderer>().sharedMaterial.SetFloat(name, val);
    }

    void GenerateSub(int inx)
    {
        var obj1 = new GameObject("objA_"+inx);
        obj1.transform.parent = gameObject.transform;
        obj1.transform.localPosition = Vector3.zero + delta * inx;
        GenerateMesh(ref obj1);
        SetMaterial(ref obj1, objA);
        SetFloatParam(ref obj1, "_Smooth", inx / 10.0f);

        var obj2 = new GameObject("objB_" + inx);
        obj2.transform.parent = gameObject.transform;
        obj2.transform.localPosition = Vector3.zero + delta * inx + spaceAB;
        GenerateMesh(ref obj2);
        SetMaterial(ref obj2, objB);
        SetFloatParam(ref obj2, "_Smooth", inx / 10.0f);

        var textVisual = GetComponent<TextVisualizer>();
        if (textVisual)
        {
            textVisual.Add(Vector3.zero + delta * inx - spaceAB, (inx / 10.0f).ToString());
        }
    }

    public void Generate()
    {
        for (int i = 0; i < 10; i++)
        {
            GenerateSub(i);
        }
    }

    public void Clear()
    {
        for (int i = this.transform.childCount; i > 0; --i)
            DestroyImmediate(this.transform.GetChild(0).gameObject);

        var textVisual = GetComponent<TextVisualizer>();
        if (textVisual)
        {
            textVisual.Clear();
        }
    }
}
