using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class WheelDataHandler : MonoBehaviour
{
    //=============================================================================================
    [SerializeField] private CarCore carCore;

    [Header("WHEEL VARIABLES")]
    public WheelData wheelData;
    [SerializeField] private GameObject wheelGameObject;
    [SerializeField] private Image buttonImage;
    [SerializeField] private TextMeshProUGUI wheelName;
    [SerializeField] private TextMeshProUGUI priceTMP;
    //=============================================================================================

    private void Start()
    {
        wheelName.text = wheelData.productName;
        buttonImage.sprite = wheelData.wheelSprite;
        priceTMP.text = "PHP " + wheelData.price.ToString("n0");
    }

    public void DisplayWheel()
    {
        wheelGameObject.SetActive(true);
    }

    public void HideWheel()
    {
        wheelGameObject.SetActive(false);
    }

    public void SelectThisWheel()
    {
        carCore.SetSelectedWheel(this);
    }

}
