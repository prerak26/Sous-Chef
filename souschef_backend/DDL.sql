create TABLE Chefs
    (
        chefId VARCHAR(40) not null,
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
        duration INTERVAL not null,
        visibility varchar(7) check (
            visibility in ('public', 'private')
        ),
        authorId varchar(40) not null,
        primary key (recipeId),
        foreign key (authorId) references Chefs on delete set null
    );

create TABLE Ingredients
    (
        ingredientId INT not null,
        name VARCHAR(150) not null,
        kind varchar(13) check (
            kind in ('whole(s)', 'gram(s)', 'cup(s)', 'can(s)', 'lb(s)', 'teaspoon(s)', 'ounce(s)', 'pinch(es)', 'bottle(s)', 'tablespoon(s)', 'ml(s)')
        ),
        primary key (ingredientId)
    );

create TABLE Steps
    (
        recipeId INT not null,
        stepNumber INT not null,
        description VARCHAR(101) not null,
        primary key (recipeId, stepNumber),
        foreign key (recipeId) references Recipes on delete cascade
    );

create TABLE Requirements
    (
        recipeId INT not null,
        ingredientId INT not null,
        quantity numeric(5,2) not null check (quantity > 0),
        primary key (recipeId, ingredientId),
        foreign key (recipeId) references Recipes on delete cascade,
        foreign key (ingredientId) references Ingredients on delete set null
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

create TABLE Bookmarks
    (
        recipeId INT not null,
        chefId VARCHAR(40) not null,
        primary key (recipeId, chefId),
        foreign key (recipeId) references Recipes on delete cascade,
        foreign key (chefId) references Chefs on delete cascade
    );

create TABLE Ratings
    (
        recipeId INT not null,
        chefId VARCHAR(40) not null,
        rating INT check (rating >= 0 and rating < 6),
        lastModified TIMESTAMP not null,
        primary key (recipeId, chefId),
        foreign key (recipeId) references Recipes on delete cascade,
        foreign key (chefId) references Chefs on delete cascade
    );

create TABLE ShoppingList
    (
        chefId VARCHAR(40) not null,
        ingredientId INT not null,
        quantity numeric(5,2) check (quantity > 0),
        primary key (chefId,ingredientId),
        foreign key (chefId) references Chefs on delete cascade,
        foreign key (ingredientId) references Ingredients on delete cascade
    );