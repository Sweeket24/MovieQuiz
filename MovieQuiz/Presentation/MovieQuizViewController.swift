import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        

        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    @IBAction func yesButtonClicked(_ sender: Any) {
        checkAnswer(true)
    }
   
    @IBAction func noButtonClicked(_ sender: Any) {
        checkAnswer(false)
    }
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    
        private var currentQuestionIndex = 0
        private var correctAnswers = 0
        
        private let questionsAmount: Int = 10
        private var questionFactory: QuestionFactoryProtocol?
        private var currentQuestion: QuizQuestion?
        private let alertPresenter = AlertPresenter()
        private let statisticService: StatisticServiceProtocol = StatisticService()
        
        // MARK: - QuestionFactoryDelegate
        
        func didReceiveNextQuestion(question: QuizQuestion?) {
            hideLoadingIndicator()
            
            guard let question = question else {
                return
            }

            currentQuestion = question
            let viewModel = convert(model: question)
            
            DispatchQueue.main.async { [weak self] in
                self?.show(quiz: viewModel)
            }
        }
        
        func didLoadDataFromServer() {
            activityIndicator.isHidden = true
            questionFactory?.requestNextQuestion()
        }
        
        func didFailToLoadData(with error: Error) {
            showNetworkError(message: error.localizedDescription)
        }
        
        private func convert(model: QuizQuestion) -> QuizStepViewModel {
            return QuizStepViewModel(
                image: UIImage(data: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        }
        
        private func show(quiz step: QuizStepViewModel) {
            imageView.image = step.image
            textLabel.text = step.question
            counterLabel.text = step.questionNumber
            
            
            imageView.layer.borderWidth = 0
        }
        
        private func show(quiz result: QuizResultsViewModel) {
            
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            
            let bestGame = statisticService.bestGame
            
            let message = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
            
            let model = AlertModel(
                title: result.title,
                message: message,
                buttonText: result.buttonText
            ) { [weak self] in
                guard let self = self else { return }

                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
            
            alertPresenter.show(in: self, model: model)
        }
        
        private func checkAnswer(_ answer: Bool) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            let isCorrect = (answer == currentQuestion.correctAnswer)
            showAnswerResult(isCorrect: isCorrect)
        }
        
        private func showAnswerResult(isCorrect: Bool) {
            if isCorrect { correctAnswers += 1 }
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 20
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.showNextQuestionOrResults()
            }
        }
        
        private func showNextQuestionOrResults() {
            if currentQuestionIndex == questionsAmount - 1 {
                let text = "Вы ответили на \(correctAnswers) из 10"
                let result = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз"
                )
                show(quiz: result)
            } else {
                currentQuestionIndex += 1
                questionFactory?.requestNextQuestion()
            }
        }
        
        // MARK: - Индикатор загрузки
        
        private func showLoadingIndicator() {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
        
        private func hideLoadingIndicator() {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
        
        private func showNetworkError(message: String) {
            hideLoadingIndicator()
            
            let model = AlertModel(
                title: "Ошибка",
                message: message,
                buttonText: "Попробовать еще раз"
            ) { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                self.questionFactory?.loadData()
            }
            
            alertPresenter.show(in: self, model: model)
        }
    }
