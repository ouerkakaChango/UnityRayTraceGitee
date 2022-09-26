using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseSystem : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public virtual void Refresh()
    {

    }

    public virtual List<string> GetLinesOf(string key)
    {
        Debug.LogError("not handle key: " + key);
        return null;
    }
}
