/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

// Firestore 문서 타입 정의 (타입스크립트의 장점 활용)
interface Review {
    // 필수 필드 (리뷰가 생성될 때 항상 존재해야 함)
    recipeId: string;       // 이 리뷰가 연결된 레시피의 ID (Firestore 문서 ID)
    rating: number;         // 사용자가 부여한 평점 (예: 1.0 ~ 5.0 사이의 숫자)
    reviewText: string;     // 리뷰 내용 (사용자가 작성한 텍스트)
    authorUid: string;      // 리뷰 작성자의 Firebase Authentication UID (누가 작성했는지 식별)
    createdAt: admin.firestore.Timestamp; // 리뷰가 작성된 시간 (Firestore Timestamp 타입)

    // 선택적 필드 (리뷰 문서에 존재할 수도 있고 안 할 수도 있음)
    uid?: string;           // Firestore 문서 ID. 실제 문서 필드는 아니지만,
                            // 코드 내에서 doc.id로 가져올 때 Review 인터페이스가 확장된 데이터를 포함할 수 있도록 옵셔널로 추가
    authorDisplayName?: string; // 리뷰 작성자의 표시 이름 (UserProfile에서 가져와 캐싱용)
    authorPhotoUrl?: string;    // 리뷰 작성자의 프로필 사진 URL (UserProfile에서 가져와 캐싱용)
    updatedAt?: admin.firestore.Timestamp; // 리뷰가 마지막으로 수정된 시간 (Firestore Timestamp 타입)
}

interface Recipe {
    // 이 필드들은 Cloud Function에 의해 업데이트됩니다.
    averageRating?: number;  // 레시피의 평균 평점
    reviewCount?: number;    // 이 레시피에 대한 총 리뷰 개수
    updatedAt?: admin.firestore.FieldValue; // 레시피 문서가 마지막으로 업데이트된 시간

    // ... 기타 recipe 필드 (이 부분은 Cloud Function이 건드리지 않을 필드들을 나타냅니다)
    // title?: string;
    // ingredients?: string[];
    // steps?: string[];
    // photoUrl?: string;
    // authorUid?: string;
    // createdAt?: admin.firestore.Timestamp;
    [key: string]: any; // 모든 문자열 키에 대해 어떤 타입의 값도 허용 (Firestore update 호환용)
}

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

/**
 * Cloud Function: updateRecipeReviewStats
 * 'reviews' 컬렉션의 문서(리뷰)가 추가, 수정, 삭제될 때마다 트리거됩니다.
 * 해당 레시피의 평균 평점과 리뷰 개수를 집계하여 'recipes' 컬렉션에 업데이트합니다.
 */
export const updateRecipeReviewStats = functions.firestore
    .document("reviews/{reviewId}")
    .onWrite(async (change, context) => {
        const reviewId = context.params.reviewId;

        // reviewData는 Review 타입으로 명시 (타입 안전성)
        const reviewData: Review | undefined = change.after.exists ? (change.after.data() as Review) : undefined;
        const oldReviewData: Review | undefined = change.before.exists ? (change.before.data() as Review) : undefined;

        let recipeId: string;
        if (reviewData?.recipeId) { // ?. (옵셔널 체이닝) 활용
            recipeId = reviewData.recipeId;
        } else if (oldReviewData?.recipeId) {
            recipeId = oldReviewData.recipeId;
        } else {
            console.log(`No recipeId found for review ${reviewId}. Exiting.`);
            return null;
        }

        const recipeRef = db.collection("recipes").doc(recipeId);
        const reviewsQuery = db.collection("reviews").where("recipeId", "==", recipeId);

        return db.runTransaction(async (transaction) => {
            const recipeDoc = await transaction.get(recipeRef);
            if (!recipeDoc.exists) {
                console.log(`Recipe ${recipeId} does not exist. Skipping stats update.`);
                return null;
            }

            const reviewsSnapshot = await transaction.get(reviewsQuery);

            let totalRating = 0;
            let reviewCount = 0;

            reviewsSnapshot.forEach(doc => {
                const review = doc.data() as Review; // Review 타입으로 캐스팅
                if (typeof review.rating === 'number') {
                    totalRating += review.rating;
                    reviewCount++;
                } else {
                    console.warn(`Review ${doc.id} for recipe ${recipeId} has invalid rating: ${review.rating}`);
                }
            });

            const averageRating = reviewCount > 0 ? (totalRating / reviewCount) : 0;

            // 업데이트할 데이터 (Recipe 타입으로 명시)
            const updateData: Recipe = {
                averageRating: averageRating,
                reviewCount: reviewCount,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            };

            transaction.update(recipeRef, updateData as Partial<Recipe>); // 타입이 명확한 updateData 사용

            console.log(`Updated stats for recipe ${recipeId}: averageRating=${averageRating.toFixed(2)}, reviewCount=${reviewCount}`);
            return null;
        });
    });
