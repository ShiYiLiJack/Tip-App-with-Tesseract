//
//  ViewController.swift
//  TipResult
//
//  Created by Jack on 5/7/19.
//  Copyright © 2019 Jack. All rights reserved.
//

import UIKit
import ProgressHUD
import TesseractOCR
import GoogleMobileAds

let defaults = UserDefaults.standard
var tax: Double = 9.75
var tip: Double = 15

class ViewController: UIViewController, UIAlertViewDelegate, G8TesseractDelegate, GADBannerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var totalPersonalLabel: UILabel!
    @IBOutlet var adBannerView: GADBannerView!
    
    @IBOutlet weak var tipButton: UIBarButtonItem!
    @IBOutlet weak var taxButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tipTableView: UITableView!
    
    let tapRec = UIGestureRecognizer()
    
    let imagePicked = UIImagePickerController()
    let operationQueue = OperationQueue()
    var finalArray: [Double] = []
    var allNumArray: [String] = []
    var personalPay: Double = 0.00
    
    @IBAction func tipButtonTapped(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        let alert = UIAlertController(title: "Tip Percent", message: "Enter Tip Percentage", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Confirm", style: .default) { (action) in
            if textfield.text != "" {
                tip = Double(textfield.text!)!
                self.tipButton.title = "Tip: \(tip)%"
                self.calcTip()
            }
        }
        alert.addTextField { (tipTextfield) in
            tipTextfield.keyboardType = .decimalPad
            tipTextfield.placeholder = "\(tip)"
            textfield = tipTextfield
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    //clear and zero the total label for the next personn
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        personalPay = 0.00
        totalPersonalLabel.text = "Total: \(personalPay)"
    }
    
    @IBAction func taxButtonTapped(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        let alert = UIAlertController(title: "Tax Percent", message: "Enter Tax Percentage", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Confirm", style: .default) { (action) in
            if textfield.text != "" {
                tax = Double(textfield.text!)!
                self.taxButton.title = "Tax: \(tax)%"
                self.calcTip()
            }
        }
        alert.addTextField { (taxTextfield) in
            
            taxTextfield.keyboardType = .decimalPad
            taxTextfield.placeholder = "\(tax)"
            textfield = taxTextfield
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //access Teseract OCR
    func recognizeImageWithTesseract(image: UIImage) {
        
        guard let operation = G8RecognitionOperation(language: "eng") else {
            fatalError("Error in operation language")
        }
        //operation.tesseract.engineMode = .lstmOnly
        operation.tesseract.pageSegmentationMode = .autoOnly
        //operation.delegate = self
        operation.tesseract.charWhitelist = "0123456789"
        operation.tesseract.image = image
        
        operation.recognitionCompleteBlock = {(tesseract: G8Tesseract?) in
            let recognizedText = tesseract?.recognizedText
            //let textString: String = (recognizedText)!
            if recognizedText != nil {
                self.splitString(detectedString: recognizedText!)
            }
            //print(textString)
            let alertController = UIAlertController(title: "OCR Result", message: recognizedText, preferredStyle: .alert)
            
            let alertAction = UIAlertAction(title: "Ok", style: .default)
            
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
            
        }
        operationQueue.addOperation(operation)
        
    }
    
    // let user take photo and sent to tesseract OCR for recognition
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            fatalError("")
        }
        
        ProgressHUD.show()
        allNumArray.removeAll()
        
        let userPicked = UIImage(named: "Receipt")
        recognizeImageWithTesseract(image: userPickedImage)
        imageView.image = userPickedImage
        imagePicked.dismiss(animated: true, completion: nil)
    }
    
    //Tokenize the result from tesseract and take only double value from the string
    func splitString(detectedString: String){
        var textArray: [String] = []
        
        let seperator = CharacterSet(charactersIn: " ,\n,$")
        textArray = detectedString.components(separatedBy: seperator)
        var x = 0
        while(x < textArray.count){
            if Double(textArray[x]) != nil {
                allNumArray.append(textArray[x])
            }
            x += 1
        }
        
        calcTip()
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row % 4 == 3 {
            personalPay = Double(round((personalPay + finalArray[indexPath.row]) * 100) / 100)
            totalPersonalLabel.text = "Total: \(personalPay)"
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let priceList = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "price")
        
        if indexPath.row % 4 == 0 {
            priceList.textLabel?.text = String(self.finalArray[indexPath.row])
        } else if indexPath.row % 4 == 1 {
            priceList.textLabel?.text = "\t Tax: \(self.finalArray[indexPath.row])"
        } else if indexPath.row % 4 == 2 {
            priceList.textLabel?.text = "\t Tip: \(self.finalArray[indexPath.row])"
        } else if indexPath.row % 4 == 3 {
            priceList.textLabel?.text = "\t Total: \(self.finalArray[indexPath.row])"
        }
        
        print(self.finalArray[indexPath.row])
        return priceList
    }
    
    func calcTip(){
        finalArray.removeAll()
        var x = 0
        //detect if there is any int and remove int
        while(x < allNumArray.count) {
            if Int(allNumArray[x]) == nil {
                let regPrice = Double(allNumArray[x])!
                let taxPrice = Double(round(regPrice * tax)/100)
                let tipPrice = Double(round((regPrice + taxPrice) * tip)/100)
                let totalPrice = Double(round((taxPrice + tipPrice + regPrice) * 100)/100)
                //print(taxPrice)
                //print(tipPrice)
                self.finalArray.append(regPrice)
                self.finalArray.append(taxPrice)
                self.finalArray.append(tipPrice)
                self.finalArray.append(totalPrice)
            }
            x += 1
        }
        print(finalArray.count)
        tipTableView.reloadData()
        ProgressHUD.dismiss()
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        present(imagePicked, animated: true, completion: nil)
        
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        print("image tapped")
        performSegue(withIdentifier: "reciptImage", sender: self)
    }
    
    //set image on imageViewController to the image selected
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ImageViewController
        destinationVC.selectedImage = imageView.image
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adBannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(adBannerView)
        //test banner
        adBannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        //App Banner
        //adBannerView.adUnitID = "ca-app-pub-8519552575120945/1025960537"
        adBannerView.rootViewController = self
        adBannerView.load(GADRequest())
        adBannerView.delegate = self
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapRec)
        tapRec.addTarget(self, action: Selector(("imageTapped")))
        
        imagePicked.delegate = self
        imagePicked.allowsEditing = true
        imagePicked.sourceType = .camera
        
        tipTableView.delegate = self
        tipTableView.dataSource = self
        tipTableView.rowHeight = 50
        
        taxButton.title = "Tax: \(tax)%"
        tipButton.title = "Tip: \(tip)%"
    }
}

