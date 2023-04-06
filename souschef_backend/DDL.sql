create TABLE Chefs
    (
        chefId INT not null,
        name VARCHAR(50),
        hashedPassword VARCHAR(80) not null,
        primary key (chefId)
    );

create TABLE Recipes
    (
        recipeId INT not null,
        title VARCHAR(50) not null,
        serves INT check (serves > 0),
        lastModified TIMESTAMP not null,
        visibility varchar(6) check (
            visibility in ('public', 'private')
        ),
        authorId INT not null,
        primary key (recipeId),
        foreign key (authorId) references Chefs on delete set null
    );

create TABLE Ingredients
    (
        ingredientId INT not null
        name VARCHAR(50) not null,
        kind varchar(11) check (
            kind in ('whole', 'grams', 'cups', 'teaspoons', 'tablespoons', 'milliliters')
        ),
        primary key (ingredientId)
    );

create TABLE Requirements
    (
        recipeId INT not null,
        stepNumber INT not null,
        serialNumber INT not null,
        ingredientId INT not null,
        quantity INT not null,
        primary key (recipeId, stepNumber, serialNumber),
        foreign key (recipeId, stepNumber) references Steps on delete cascade,
        foreign key (ingredientId) references Ingredients on delete null
    );

create TABLE Tags
    (
        tagId INT not null,
        name VARCHAR(50) not null,
        primary key (tagId)
    );

create TABLE Tagged
    (
        recipeId INT not null,
        tagId INT not null,
        primary key (recipeId, tagId),
        foreign key (recipeId) references Recipes on delete cascade,
        foreign key (tagId) references Tags on delete cascade
    );

create TABLE Steps
    (
        recipeId INT not null,
        stepNumber INT not null,
        description VARCHAR(500) not null,
        primary key (recipeId, stepNumber),
        foreign key (recipeId) references Recipes on delete cascade
    );

create TABLE Bookmarks
    (
        recipeId INT not null,
        chefId INT not null,
        primary key (recipeId, chefId),
        foreign key (recipeId) references Recipes on delete cascade,
        foreign key (chefId) references Chefs on delete cascade
    );

create TABLE Ratings
    (
        recipeId INT not null,
        chefId INT not null,
        rating INT check (rating > 0 and rating < 6),
        lastModified TIMESTAMP not null,
        primary key (recipeId, chefId),
        foreign key (recipeId) references Recipes on delete cascade,
        foreign key (chefId) references Chefs on delete cascade
    );

create TABLE ShoppingList
    (
        chefId INT not null,
        ingredientId INT not null,
        quantity INT check (quantity > 0),
        primary key (chefId,ingredientId),
        foreign key (chefId) references Chefs on delete cascade,
        foreign key (ingredientId) references Ingredients on delete cascade
    );