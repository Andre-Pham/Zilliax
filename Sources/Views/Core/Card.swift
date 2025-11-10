//
//  Card.swift
//  https://github.com/Andre-Pham/Zilliax
//
//  Created by Andre Pham.
//

public class Card: View {
    public override func setup() {
        super.setup()

        self.setBackgroundColor(to: Colors.fillBackground)
            .setCornerRadius(to: 16)
    }
}
