using FlutterUnityIntegration;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class CarCore : MonoBehaviour
{
    //=============================================================================================
    [SerializeField][ReadOnly] private WheelDataHandler SelectedWheel;
    [SerializeField][ReadOnly] private ColorSelector SelectedColorSelector;
    [SerializeField] private UnityMessageManager UnityMessageManager;

    [Header("SELECTED CAR VARIABLES")]
    [SerializeField] private List<GameObject> CarModels;
    [SerializeField] private int CurrentCarIndex;

    [Header("SELECTED WHEEL VARIABLES")]
    [SerializeField] private TextMeshProUGUI SelectedWheelNameTMP;
    [SerializeField] private TextMeshProUGUI PriceTMP;
    [SerializeField] private Button AddToCartBtn;

    [Header("AVAILABLE WHEELS")]
    [SerializeField] private List<WheelDataHandler> allWheelHandlers;

    [Header("SELECTED COLOR")]
    [SerializeField] private Material SelectedMaterial;

    [Header("PROPER PANELS")]
    [SerializeField][ReadOnly] private bool isDisplayingWheels;
    [SerializeField] private GameObject WheelsPanel;
    [SerializeField] private GameObject PaintJobPanel;
    [SerializeField] private TextMeshProUGUI PurchaseTMP;
    [SerializeField] private Button WheelsBtn;
    [SerializeField] private Button PaintJobBtn;
    //=============================================================================================

    private void Awake()
    {
        SelectedMaterial.color = Color.white;
    }
    private void OnApplicationQuit()
    {
        SelectedMaterial.color = Color.white;
    }

    public void InitializeCarScene()
    {
        SelectedWheelNameTMP.text = "SELECT YOUR WHEEL";
        PriceTMP.text = "";
        AddToCartBtn.interactable = false;
    }

    public void SetSelectedWheel(WheelDataHandler wheelDataHandler)
    {
        SelectedWheel = wheelDataHandler;
        SelectedWheelNameTMP.text = SelectedWheel.wheelData.productName;
        PriceTMP.text = "PHP " + SelectedWheel.wheelData.price.ToString("n0");
        AddToCartBtn.interactable = true;
        foreach (var wheel in allWheelHandlers)
            wheel.HideWheel();
        SelectedWheel.DisplayWheel();
    }

    public void SetSelectedPaintJob(ColorSelector colorSelector)
    {
        SelectedColorSelector = colorSelector;
        SelectedWheelNameTMP.text = SelectedColorSelector.paintJobData.serviceName;
        PriceTMP.text = "PHP " + SelectedColorSelector.paintJobData.price.ToString("n0");
        AddToCartBtn.interactable = true;
        SetSelectedMaterialColor(SelectedColorSelector.paintJobData.color);
    }

    public void DisplayProperCar()
    {
        foreach (var car in CarModels)
            car.SetActive(false);
        CarModels[CurrentCarIndex].SetActive(true);
    }

    public void IncrementCarIndex()
    {
       CurrentCarIndex++;
        if (CarModels.Count == CurrentCarIndex)
            CurrentCarIndex = 0;
        DisplayProperCar();
    }

    public void DecrementCarIndex()
    {
        CurrentCarIndex--;
        if (CurrentCarIndex == -1)
            CurrentCarIndex = CarModels.Count - 1;
        DisplayProperCar();
    }

    public void SetSelectedMaterialColor(Color color)
    {
        SelectedMaterial.color = color; 
    }

    public void SelectRed()
    {
        SetSelectedMaterialColor(new Color(255,0,0));
    }

    public void SelectCyan()
    {
        SetSelectedMaterialColor(new Color(0, 255, 255));
    }

    public void DisplayWheels()
    {
        isDisplayingWheels = true;
        WheelsPanel.SetActive(true);
        PaintJobPanel.SetActive(false);
        PurchaseTMP.text = "BUY WHEEL";
        PurchaseTMP.fontSize = 64;
        WheelsBtn.interactable = false;
        WheelsBtn.GetComponent<RectTransform>().localScale = Vector3.one;
        PaintJobBtn.interactable = true;
        PaintJobBtn.GetComponent<RectTransform>().localScale = new Vector3(0.8f, 0.8f,1);
    }

    public void DisplayPaintJobs()
    {
        isDisplayingWheels = false;
        WheelsPanel.SetActive(false);
        PaintJobPanel.SetActive(true);
        PurchaseTMP.text = "AVAIL PAINT JOB";
        PurchaseTMP.fontSize = 48;
        WheelsBtn.interactable = true;
        WheelsBtn.GetComponent<RectTransform>().localScale = new Vector3(0.8f, 0.8f, 1);
        PaintJobBtn.interactable = false;
        PaintJobBtn.GetComponent<RectTransform>().localScale = Vector3.one;

    }

    public void TogglePanel()
    {
        //isDisplayingWheels = !isDisplayingWheels;
        if (isDisplayingWheels)
        {
            WheelsPanel.SetActive(true);
            PaintJobPanel.SetActive(false);
            PurchaseTMP.text = "BUY WHEEL";
            PurchaseTMP.fontSize = 64;
        }
        else
        {
            WheelsPanel.SetActive(false);
            PaintJobPanel.SetActive(true);
            PurchaseTMP.text = "AVAIL PAINT JOB";
            PurchaseTMP.fontSize = 48;
        }
    }

    public void SendMessageToFlutter()
    {
        if(isDisplayingWheels)
            UnityMessageManager.SendMessageToFlutter("PRODUCT/" + SelectedWheel.wheelData.productID);
        else
            UnityMessageManager.SendMessageToFlutter("SERVICE/" + SelectedColorSelector.paintJobData.serviceID);
    }
}
