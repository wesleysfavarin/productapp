//
//  WesleyFavarinTestTests.swift
//  WesleyFavarinTestTests
//
//  Created by Wesley Favarin on 02/10/24.
//

import XCTest
@testable import WesleyFavarinTest

class ProductServiceTests: XCTestCase {

    var productService: ProductService!

    override func setUpWithError() throws {
        super.setUp()
        productService = ProductService()
    }

    override func tearDownWithError() throws {
        productService = nil
        super.tearDown()
    }

    func testFetchProductsSuccess() {
        // Espera o resultado da requisição de produtos
        let expectation = self.expectation(description: "Fetch products from API")
        
        productService.fetchProducts { result in
            switch result {
            case .success(let digioStore):
                XCTAssertNotNil(digioStore, "Os dados não devem ser nulos")
                XCTAssertGreaterThan(digioStore.spotlight.count, 0, "Spotlight deve conter itens")
                XCTAssertGreaterThan(digioStore.products.count, 0, "Products deve conter itens")
                XCTAssertNotNil(digioStore.cash, "Cash não deve ser nulo")
                
            case .failure(let error):
                XCTFail("Erro ao buscar produtos: \(error)")
            }
            expectation.fulfill() // Sinaliza que o teste foi concluído
        }

        waitForExpectations(timeout: 5, handler: nil) // Aguarda a conclusão com timeout
    }

    func testFetchProductsFailure() {
        // Simula uma URL inválida para garantir que o erro seja tratado corretamente
        var invalidProductService = ProductService()
        invalidProductService.urlString = "https://invalidurl.com"

        let expectation = self.expectation(description: "Fetch products from invalid API")

        invalidProductService.fetchProducts { result in
            switch result {
            case .success:
                XCTFail("Deveria ter retornado um erro para a URL inválida")
                
            case .failure(let error):
                XCTAssertNotNil(error, "Deve retornar um erro")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}

/// ViewModel Tests
class ProductViewModelTests: XCTestCase {

    var viewModel: ProductViewModel!
    var mockService: MockProductService!

    override func setUpWithError() throws {
        super.setUp()
        mockService = MockProductService()
        viewModel = ProductViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }

    func testFetchProductsSuccess() {
        // Defina o serviço de mock com dados válidos
        mockService.mockData = DigioStore(spotlight: [
            Spotlight(name: "Recarga", bannerURL: "", description: "Descrição de recarga")
        ], products: [
            Product(name: "XBOX", imageURL: "", description: "Descrição do XBOX")
        ], cash: Cash(title: "digio Cash", bannerURL: "", description: "Descrição de digio Cash"))

        let expectation = self.expectation(description: "Fetch products from mock service")
        
        viewModel.fetchProducts()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewModel.getSpotlightCount(), 1)
            XCTAssertEqual(self.viewModel.getProductCount(), 1)
            XCTAssertNotNil(self.viewModel.getCash())
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testFetchProductsFailure() {
        // Defina o serviço de mock com erro
        mockService.shouldReturnError = true

        let expectation = self.expectation(description: "Handle error from mock service")

        viewModel.fetchProducts()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewModel.getSpotlightCount(), 0)
            XCTAssertEqual(self.viewModel.getProductCount(), 0)
            XCTAssertNil(self.viewModel.getCash())
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }
}

class MockProductService: ProductService {
    
    var mockData: DigioStore?
    var shouldReturnError = false
    
    override func fetchProducts(completion: @escaping (Result<DigioStore, Error>) -> Void) {
        if shouldReturnError {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro simulado"])
            completion(.failure(error))
        } else if let data = mockData {
            completion(.success(data))
        }
    }
}
