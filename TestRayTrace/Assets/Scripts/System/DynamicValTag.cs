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

    public float GetVal()
    {
        if(type == DynamicType.Default)
        {
            return val;
        }
        else if (type == DynamicType.Curve)
        {
            float time = Shader.GetGlobalVector("_Time").y;
            return cv.Evaluate(time);
        }
        else
        {
            Debug.LogError("Not handled");
        }
        return 0;
    }
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
