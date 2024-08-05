using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ColorSelector : MonoBehaviour
{
    [SerializeField] private CarCore CarCore;
    [SerializeField] private TextMeshProUGUI LabelTMP;
   public PaintJobData paintJobData;

    private void Start()
    {
        gameObject.GetComponent<Image>().color = paintJobData.color;
        LabelTMP.text = paintJobData.serviceName;
    }
    public void SelectThisColor()
    {
        CarCore.SetSelectedPaintJob(this);
    }


}
