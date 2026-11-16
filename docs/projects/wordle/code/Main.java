import java.io.IOException;
import java.io.FileReader;
import java.util.ArrayList;
import java.io.FileNotFoundException;
import java.lang.IllegalArgumentException;
import java.util.Scanner;

/**
 * Main Class for Wordle Game
 * @authors Lizzie Healy and Emily Oh
 * @version May 8th, 2024
 */

public class Main {

	public static void main (String [] args) {
       		char[][] allWords = new char[5757][5];
			String csvFileName = "wordlewords.csv";

        	try {
            		CSVReader reader = new CSVReader();
            		FileReader input = new FileReader(csvFileName);
            		ArrayList<String[]> myEntries = reader.read(input);
            		reader.close();
			
			int i = 0;
			for (String[] words : myEntries) {
				String word = words[0];
				char one = word.charAt(0);
				char two = word.charAt(1);
				char three = word.charAt(2);
				char four = word.charAt(3);
				char five = word.charAt(4);

				char[] letters = new char[5];
				letters[0] = one;
				letters[1] = two;
				letters[2] = three;
				letters[3] = four;
				letters[4] = five;
			
				allWords[i] = letters;
				i++;
			}
                }
        	catch (FileNotFoundException e) {
            		System.err.println("File Not Found");
        	}

			//Starting the Game:
			System.out.println("Hi, Welcome to Wordle");
			String wordleWord = "";
			Wordle wordle = new Wordle(wordleWord);
			char[] answer = wordle.pickWord(allWords);
			
			boolean correct = false;
			for (int j = 0; j < 6; j++) {
				System.out.println("Please enter a guess: ");
				Scanner sc = new Scanner(System.in);
				String strGuess = sc.nextLine().toLowerCase();
				char[] guess = new char[5];
				if (strGuess.length() != 5) {
					System.out.println("");
				}
				else {
					for (int i = 0; i < 5; i++) {
						guess[i] = strGuess.charAt(i);
					}
				}
			
				boolean check = wordle.isWord(guess, allWords);
				if (check == false)  {
					System.out.println("Must input a 5-letter word");
					j--;
				}
				else {
					correct = wordle.correct(guess, answer);
					if (correct == true) {
						wordle.color(strGuess, answer);
						System.out.println("You win!");
						break;
					}
					else {
						wordle.color(strGuess, answer);
					}
				}
			}
			if (correct == false) {
				System.out.println("You lost");
				String ans = "";
				for (int i = 0; i<5; i++) {
					ans += answer[i];
				}
				System.out.println("The word was: " + ans);
			}	
	}	
}

