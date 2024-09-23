using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ColorSelector : MonoBehaviour
{
    [SerializeField] private CarCore CarCore;
    [SerializeField] private Image CarColorImage;
    [SerializeField] private TextMeshProUGUI LabelTMP;
    [SerializeField] private TextMeshProUGUI PriceTMP;
   public PaintJobData paintJobData;

    private void Start()
    {
        if(CarColorImage != null)
            CarColorImage.color = paintJobData.color;
        LabelTMP.text = paintJobData.serviceName;
        if(PriceTMP != null ) 
            PriceTMP.text = "PHP " + paintJobData.price.ToString("n0");
    }
    public void SelectThisColor()
    {
        CarCore.SetSelectedPaintJob(this);
    }


}
