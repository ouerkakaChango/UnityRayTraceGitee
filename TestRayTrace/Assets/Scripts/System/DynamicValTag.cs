using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum DynamicType
{
    Default,
    Curve,
}

[System.Serializable]
public struct DynamicFloat
{
    public DynamicType type;
    public string name;
    public float val;
    public AnimationCurve cv;
}

public class DynamicValTag : MonoBehaviour
{
    [HideInInspector, SerializeField]
    public List<DynamicFloat> floatVals = new List<DynamicFloat>();
    
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
