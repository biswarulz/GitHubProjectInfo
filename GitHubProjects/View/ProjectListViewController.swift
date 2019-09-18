//
//  ProjectListViewController.swift
//  GitHubProjects
//
//  Created by Biswajyoti Sahu on 17/09/19.
//  Copyright © 2019 Biswajyoti Sahu. All rights reserved.
//

import UIKit

class ProjectListViewController: UIViewController {
    
    @IBOutlet weak var projectListTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshBarButton: UIBarButtonItem!
    
    
    lazy var viewModel: ProjectListViewModel = {
        return ProjectListViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initViewModel()
    }
    
    func initView() {
        navigationItem.title = "Project Lists"
        refreshBarButton.isEnabled = false
        projectListTableView.estimatedRowHeight = 100
        projectListTableView.rowHeight = UITableView.automaticDimension
    }
    
    func initViewModel() {
        
        viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.refreshBarButton.isEnabled = true
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert( message )
                }
            }
        }
        
        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    self?.activityIndicator.isHidden = false
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.projectListTableView.alpha = 0.0
                    })
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.projectListTableView.alpha = 1.0
                    })
                }
            }
        }
        
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.projectListTableView.reloadData()
            }
        }
        
        viewModel.initFetch()
        
    }
    
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func didTapOnRefreshList(_ sender: Any) {
        viewModel.initFetch()
    }
    
}

extension ProjectListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectListCellIdentifier", for: indexPath) as? ProjectListTableViewCell else {
            return UITableViewCell()
        }
        
        let cellVM = viewModel.getCellViewModel(at: indexPath)
        let imageURL = URL(string: cellVM.avatarImagePath)!
        viewModel.fetchImageData(imageURL) { (imageData) in
            DispatchQueue.main.async {
                cell.avatarImageView.image = UIImage(data: imageData)
            }
        }
        cell.projectListCellViewModel = cellVM
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.tappedCell(at: indexPath)
        performSegue(withIdentifier: "ProjectDetailVC", sender: nil)
    }
}

extension ProjectListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProjectDetailVC", let controller = segue.destination as? ProjectDetailViewController, let item = viewModel.selectedItem {
            controller.detailViewModel.selectedItem = item
        }
    }
}

class ProjectListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    var projectListCellViewModel: ProjectListCellViewModel?  {
        didSet {
            projectNameLabel.text = projectListCellViewModel?.projectName
            authorLabel.text = "By \(projectListCellViewModel?.author ?? "")"
        }
    }
}

