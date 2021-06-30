import UIKit

final class ViewController: UIViewController {

    // MARK: - Properties
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        }
        return UIApplication.shared.statusBarOrientation
    }

    private var swipeGestureRecognizer = UISwipeGestureRecognizer()
    private var selectedImageViewButton = 0
    private let picker = UIImagePickerController()
    // keep track of the number of images set by the user, if equal 0 an alert is shown after the swipe and before the share
    private var numberOfImages = 0

    // MARK: - Outlets
    @IBOutlet weak var swipeArrowImageView: UIImageView!
    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var centralView: UIView!
    @IBOutlet var presentationButtons: [UIButton]!
    @IBOutlet var imageViewButtons: [UIButton]!

    // MARK: - Cycle View life Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe))
        
        centralView.addGestureRecognizer(swipeGestureRecognizer)
        
        picker.delegate = self
        
        presentationButtons[1].isSelected = true
        imageViewButtons[3].isHidden = true

        imageViewButtons.forEach { button in
            button.imageView?.contentMode = .scaleAspectFill
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        swipeGestureUpdate()
    }
    // MARK: - Methods
    // MARK: - Keep track of the device orientation
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.swipeGestureUpdate()
        }, completion: nil)
    }

    // MARK: - Set centralView layout methods
    @IBAction func presentationButtonsTapped(_ sender: UIButton) {
        if sender.isSelected {
            return
        }
        presentationButtons.forEach { button in
            button.isSelected = false
        }
        sender.isSelected = true
        setCentralView(sender: sender)
    }

    private func setCentralView(sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: [], animations: {
            switch sender.tag {
            case 1:
                self.imageViewButtons.forEach { $0.isHidden = $0.tag == 1 ? true : false}
            case 2:
                self.imageViewButtons.forEach { $0.isHidden = $0.tag == 2 ? true : false}
            case 3:
                self.imageViewButtons.forEach { $0.isHidden = false}
            default:
                break
            }
        }, completion: nil)
    }

    // MARK: - Set Images of the centralView
    // change the layout of the centralView
    @IBAction func imageViewButtonTapped(_ sender: UIButton) {
        selectedImageViewButton = sender.tag
        setPicker()
    }

    // present ImagePickerController
    private func setPicker() {
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    // set the image of the button selected
    private func setImage(selectedButton: Int, image: UIImage) {
        imageViewButtons[selectedButton].setImage(image, for: .normal)
    }

    // MARK: - Swipe gesture methods
    private func swipeGestureUpdate() {
        // update the direction and views based on the orientation
        if let orientation = windowInterfaceOrientation {
            if orientation.isPortrait {
                // set the swipe gesture according to the device orientation
                swipeGestureRecognizer.direction = .up
                // set the image and the label
                swipeArrowImageView.image = UIImage(named: "Arrow Up")
                swipeLabel.text = "Swipe up to share"
            } else if orientation.isLandscape {
                swipeGestureRecognizer.direction = .left
                swipeArrowImageView.image = UIImage(named: "Arrow Left")
                swipeLabel.text = "Swipe left to share"
            }
        }
    }

    // func called when the user swipe the view
    @objc
    private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        // get the actual frame of the view
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height

        UIView.animate(withDuration: 0.3) {
            if self.swipeGestureRecognizer.direction == .left {
                self.centralView.transform = CGAffineTransform.init(translationX: -screenWidth, y: 0)
            } else if self.swipeGestureRecognizer.direction == .up {
                self.centralView.transform = CGAffineTransform.init(translationX: 0, y: -screenHeight)
            }
        } completion: { _ in
            if self.numberOfImages == 0 {
                self.noImageAlert()
            } else {
            self.shareImage()
        }
        }
    }
    // MARK: - Share image methods

    // share the snapshot of the centralView
    private func shareImage() {
        let activityController = UIActivityViewController(activityItems: [centralView.image], applicationActivities: [])
        present(activityController, animated: true, completion: nil)
        activityController.completionWithItemsHandler = { _, _, _, _ in
            self.centralView.alpha = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.centralView.transform = .identity
                self.centralView.alpha = 1
            }, completion: nil)
        }
    }
    
    // alert shown before the share if the user has never added an image
    func noImageAlert() {
        let alert = UIAlertController(title: "You haven't added any images!", message: "Are you sure you want to share this creation?", preferredStyle: .alert)
        let actionShare = UIAlertAction(title: "Yes", style: .default) { _ in
            self.shareImage()
        }
        let actionDontShare = UIAlertAction(title: "No", style: .default) { _ in
            UIView.animate(withDuration: 0.2) {
                self.centralView.transform = .identity
            }
        }
        alert.addAction(actionShare)
        alert.addAction(actionDontShare)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerController
extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        setImage(selectedButton: self.selectedImageViewButton, image: image)
        dismiss(animated: true, completion: nil)
    }
}
