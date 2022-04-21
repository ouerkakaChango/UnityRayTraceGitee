using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SDFBakerMgr : MonoBehaviour
{
    public List<string> bakedLines = new List<string>();

    bool hide = false;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //###
    public void Bake()
    {
        bakedLines.Clear();
        SDFBakerTag[] tags = (SDFBakerTag[])GameObject.FindObjectsOfType(typeof(SDFBakerTag));
        foreach(var tag in tags)
        {
            AddBake(tag.gameObject);
        }
    }

    void AddBake(GameObject obj)
    {
        var mf = obj.GetComponent<MeshFilter>();
        var mr = obj.GetComponent<MeshRenderer>();
        if(mf&&mr)
        {
            var meshName = mf.sharedMesh.name;
            Debug.Log(meshName);
            if(meshName == "Cube")
            {
                AddBakeCube(obj);
            }
        }
    }

    void AddBakeCube(GameObject obj)
    {
        bakedLines.Add("SDFBox(p, " + obj.transform.position + ", " + obj.transform.localScale + ", " + obj.transform.rotation.eulerAngles);
    }

    public void ToggleHideTransform()
    {
        hide = !hide;
        if (hide)
        {
            transform.hideFlags = HideFlags.NotEditable | HideFlags.HideInInspector;
        }
        else
        {
            transform.hideFlags = HideFlags.None;
        }
    }
}
