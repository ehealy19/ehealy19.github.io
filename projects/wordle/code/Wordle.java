import java.util.Arrays;
import java.util.Random;
import java.util.Scanner;

/**
 * Wordle Class for Wordle Game
 * @authors Lizzie Healy and Emily Oh
 * @version May 8th, 2024
 */
public class Wordle {

	private String wordleWord;
	private String[] guessArray = new String[5];
	private int currentGuessIndex = 0;

	public Wordle(String wordleWord) {
		this.wordleWord = wordleWord;
	}

	public void fillArray() {
		Scanner scanner = new Scanner(System.in);
		while (currentGuessIndex < 5) {
			System.out.print("Enter your 5-letter word guess: ");
			String guess = scanner.nextLine();
			if (guess.length() != 5) {
				System.out.println("Please enter exactly 5 letters.");
				continue;
			}
			guessArray[currentGuessIndex] = guess;
			currentGuessIndex++;
			if (guess.equals(wordleWord)) {
				System.out.println("Congratulations! You've guessed the word!");
				break;
			}
		}
		if (currentGuessIndex >= 5) {
			System.out.println("You've used all your guesses. The word was: " + wordleWord);
		}
		scanner.close();
	}

	public void color(String currentGuess, char[] answer) {
		StringBuilder b = new StringBuilder();
		final String ANSI_RESET = "\u001B[0m";
		final String ANSI_GREEN = "\u001B[32m";
		final String ANSI_YELLOW = "\u001B[33m";

		for (int i = 0; i < currentGuess.length(); i++) {
			char x = currentGuess.charAt(i);
			if (answer[i] == x) {
				b.append(ANSI_GREEN).append(x).append(ANSI_RESET);
			} else if (containsChar(answer, x)) {
				b.append(ANSI_YELLOW).append(x).append(ANSI_RESET);
			} else {
				b.append(x);
			}
		}
		System.out.println(b.toString());
	}

	private boolean containsChar(char[] array, char c) {
		for (char ch : array) {
			if (ch == c) {
				return true;
			}
		}
		return false;
	}

	public char[] pickWord(char[][] allWords) {
		if (allWords.length == 0) {
			return null;
		}
		Random random = new Random();
		int randomIndex = random.nextInt(allWords.length);
		return allWords[randomIndex];
	}

	public boolean isWord(char[] guess, char[][] allWords) {
		for (char[] word : allWords) {
			if (Arrays.equals(guess,word)) {
				return true;
			}
		}
		return false;
	}

	public boolean correct(char[] guess, char[] answer) {
		boolean correct = true;
		for (int i = 0; i < 5; i++) {
			if (guess[i] != answer[i]) {
				correct = false;
			}
		}
		return correct;
	}
}

