create TABLE Chefs
    (
        chefId VARCHAR(25) not null,
        name VARCHAR(50),
        hashedPassword VARCHAR(80) not null,
        primary key (chefId)
    );

create TABLE Recipes
    (
        recipeId VARCHAR(25),
        title VARCHAR(50) not null,
        timestamp TIMESTAMP not null,
        visibility varchar(6) check (
            visibility in ('public', 'private')
        ),
        authorId VARCHAR(25) not null,
        primary key (recipeId),
        foreign key (authorId) references Chefs on delete set null
    );

create TABLE Ingredients
    (
        ingredientId VARCHAR(25),
        name VARCHAR(50) not null,
        primary key (ingredientId)
    );

create TABLE Requirements
    (
        recipeId VARCHAR(25),
        ingredientId VARCHAR(25),
        quantity VARCHAR(50) not null,
        primary key (recipeId, ingredientId),
        foreign key (recipeId) references Recipes on delete cascade,
        foreign key (ingredientId) references Ingredients on delete cascade
    );

create TABLE Tags
    (
        tagId VARCHAR(25),
        name VARCHAR(50) not null,
        primary key (tagId)
    );

create TABLE Tagged
    (
        recipeId VARCHAR(25),
        tagId VARCHAR(25),
        primary key (recipeId, tagId),
        foreign key (recipeId) references Recipes on delete cascade,
        foreign key (tagId) references Tags on delete cascade
    );

create TABLE Steps
    (
        recipeId VARCHAR(25),
        stepNumber INT not null,
        description VARCHAR(500) not null,
        primary key (recipeId, stepNumber),
        foreign key (recipeId) references Recipes on delete cascade
    );

create TABLE Comments
    (
        commentId VARCHAR(25),
        recipeId VARCHAR(25),
        timestamp TIMESTAMP not null,
        authorId VARCHAR(25) not null,
        content VARCHAR(500) not null,
        primary key (commentId),
        foreign key (recipeId) references Recipes on delete cascade,
        foreign key (authorId) references Chefs on delete set null
    );

create TABLE Likes
    (
        recipeId VARCHAR(25),
        chefId VARCHAR(25),
        primary key (recipeId, chefId),
        foreign key (recipeId) references Recipes on delete cascade,
        foreign key (chefId) references Chefs on delete cascade
    );

create TABLE Inventory
    (
        chefId VARCHAR(25),
        ingredientId VARCHAR(25),
        quantity numeric(8, 2) check (budget > 0),
        primary key (chefId,ingredientId),
        foreign key (chefId) references Chefs on delete cascade,
        foreign key (ingredientId) references Ingredients on delete cascade
    );

create TABLE ShoppingList
    (
        chefId VARCHAR(25),
        ingredientId VARCHAR(25),
        quantity numeric(8, 2) check (budget > 0),
        primary key (chefId,ingredientId),
        foreign key (chefId) references Chefs on delete cascade,
        foreign key (ingredientId) references Ingredients on delete cascade
    );